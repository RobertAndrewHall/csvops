# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/menu_loop"
require "csvtool/application/use_cases/run_extraction"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/value_streamer"
require "csvtool/infrastructure/output/console_writer"

module Csvtool
  class CLI
    MENU_OPTIONS = [
      "Extract column",
      "Exit"
    ].freeze

    def self.start(argv, stdin:, stdout:, stderr:)
      new(argv, stdin: stdin, stdout: stdout, stderr: stderr).run
    end

    def initialize(argv, stdin:, stdout:, stderr:)
      @argv = argv
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
    end

    def run
      case @argv.first
      when "menu"
        run_menu_loop
      when "column"
        run_column_command
      else
        print_usage
        1
      end
    end

    private

    def run_menu_loop
      extract_action = -> { Application::UseCases::RunExtraction.new(stdin: @stdin, stdout: @stdout).call }
      Interface::CLI::MenuLoop.new(
        stdin: @stdin,
        stdout: @stdout,
        menu_options: MENU_OPTIONS,
        extract_action: extract_action
      ).run
    end

    def print_usage
      @stderr.puts "Usage:"
      @stderr.puts "  csvtool menu"
      @stderr.puts "  csvtool column <file> <column>"
    end

    def run_column_command
      file_path = @argv[1]
      column_name = @argv[2]
      unless file_path && column_name
        print_usage
        return 1
      end

      errors = Interface::CLI::Errors::Presenter.new(stdout: @stdout)
      return errors.file_not_found(file_path) || 1 unless File.file?(file_path)

      header_reader = Infrastructure::CSV::HeaderReader.new
      headers = header_reader.call(file_path: file_path, col_sep: ",")
      return errors.no_headers || 1 if headers.empty?
      return errors.column_not_found || 1 unless headers.include?(column_name)

      value_streamer = Infrastructure::CSV::ValueStreamer.new
      writer = Infrastructure::Output::ConsoleWriter.new(stdout: @stdout, value_streamer: value_streamer)
      writer.call(file_path: file_path, column_name: column_name, col_sep: ",", skip_blanks: true)
      0
    rescue CSV::MalformedCSVError
      errors.could_not_parse_csv
      1
    rescue Errno::EACCES
      errors.cannot_read_file(file_path)
      1
    end
  end
end
