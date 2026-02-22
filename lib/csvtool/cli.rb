# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/menu_loop"
require "csvtool/interface/cli/workflows/run_extraction_workflow"
require "csvtool/interface/cli/workflows/run_row_extraction_workflow"
require "csvtool/interface/cli/workflows/run_row_randomization_workflow"
require "csvtool/interface/cli/workflows/run_cross_csv_dedupe_workflow"
require "csvtool/interface/cli/workflows/run_csv_parity_workflow"
require "csvtool/interface/cli/workflows/run_csv_split_workflow"
require "csvtool/interface/cli/workflows/run_csv_stats_workflow"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/value_streamer"
require "csvtool/infrastructure/output/console_writer"
require "csvtool/application/use_cases/run_csv_stats"
require "csvtool/domain/csv_stats_session/stats_source"
require "csvtool/domain/csv_stats_session/stats_options"
require "csvtool/domain/csv_stats_session/stats_session"
require "csvtool/domain/shared/output_destination"

module Csvtool
  class CLI
    MENU_OPTIONS = [
      "Extract column",
      "Extract rows (range)",
      "Randomize rows",
      "Dedupe using another CSV",
      "Validate parity",
      "Split CSV into chunks",
      "CSV stats summary",
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
      when "stats"
        run_stats_command
      else
        print_usage
        1
      end
    end

    private

    def run_menu_loop
      extract_column_action = -> { Interface::CLI::Workflows::RunExtractionWorkflow.new(stdin: @stdin, stdout: @stdout).call }
      extract_rows_action = -> { Interface::CLI::Workflows::RunRowExtractionWorkflow.new(stdin: @stdin, stdout: @stdout).call }
      randomize_rows_action = -> { Interface::CLI::Workflows::RunRowRandomizationWorkflow.new(stdin: @stdin, stdout: @stdout).call }
      dedupe_action = -> { Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow.new(stdin: @stdin, stdout: @stdout).call }
      parity_action = -> { Interface::CLI::Workflows::RunCsvParityWorkflow.new(stdin: @stdin, stdout: @stdout).call }
      split_action = -> { Interface::CLI::Workflows::RunCsvSplitWorkflow.new(stdin: @stdin, stdout: @stdout).call }
      stats_action = -> { Interface::CLI::Workflows::RunCsvStatsWorkflow.new(stdin: @stdin, stdout: @stdout).call }
      Interface::CLI::MenuLoop.new(
        stdin: @stdin,
        stdout: @stdout,
        menu_options: MENU_OPTIONS,
        extract_column_action: extract_column_action,
        extract_rows_action: extract_rows_action,
        randomize_rows_action: randomize_rows_action,
        dedupe_action: dedupe_action,
        parity_action: parity_action,
        split_action: split_action,
        stats_action: stats_action
      ).run
    end

    def print_usage
      @stderr.puts "Usage:"
      @stderr.puts "  csvtool menu"
      @stderr.puts "  csvtool column <file> <column>"
      @stderr.puts "  csvtool stats <file>"
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

    def run_stats_command
      file_path = @argv[1]
      unless file_path
        print_usage
        return 1
      end

      errors = Interface::CLI::Errors::Presenter.new(stdout: @stderr)
      source = Domain::CsvStatsSession::StatsSource.new(path: file_path, separator: ",", headers_present: true)
      options = Domain::CsvStatsSession::StatsOptions.new
      destination = Domain::Shared::OutputDestination.console
      session = Domain::CsvStatsSession::StatsSession.start(source: source, options: options).with_output_destination(destination)
      result = Application::UseCases::RunCsvStats.new.call(session: session)

      unless result.ok?
        case result.error
        when :file_not_found
          errors.file_not_found(result.data[:path])
        when :could_not_parse_csv
          errors.could_not_parse_csv
        when :cannot_read_file
          errors.cannot_read_file(result.data[:path])
        else
          @stderr.puts "Unknown error."
        end
        return 1
      end

      @stdout.puts "CSV Stats Summary"
      @stdout.puts "Rows: #{result.data[:row_count]}"
      @stdout.puts "Columns: #{result.data[:column_count]}"
      @stdout.puts "Headers: #{result.data[:headers].join(', ')}" unless result.data[:headers].nil? || result.data[:headers].empty?
      if result.data[:column_stats] && !result.data[:column_stats].empty?
        @stdout.puts "Column completeness:"
        result.data[:column_stats].each do |stats|
          @stdout.puts "  #{stats[:name]}: non_blank=#{stats[:non_blank_count]} blank=#{stats[:blank_count]}"
        end
      end

      0
    end
  end
end
