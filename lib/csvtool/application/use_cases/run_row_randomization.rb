# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/row_randomizer"

module Csvtool
  module Application
    module UseCases
      class RunRowRandomization
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
          @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
          @header_reader = Infrastructure::CSV::HeaderReader.new
          @row_randomizer = Infrastructure::CSV::RowRandomizer.new
        end

        def call
          file_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          return @errors.file_not_found(file_path) unless File.file?(file_path)
          headers = @header_reader.call(file_path: file_path, col_sep: ",")
          return @errors.no_headers if headers.empty?

          rows = @row_randomizer.call(file_path: file_path, col_sep: ",")
          output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
            stdin: @stdin,
            stdout: @stdout,
            errors: @errors
          ).call
          return if output_destination.nil?

          if output_destination[:mode] == :file
            write_output_file(output_destination[:path], headers, rows)
          else
            print_to_console(headers, rows)
          end
        rescue CSV::MalformedCSVError
          @errors.could_not_parse_csv
        rescue Errno::EACCES
          @errors.cannot_read_file(file_path)
        end

        private

        def print_to_console(headers, rows)
          @stdout.puts
          @stdout.puts ::CSV.generate_line(headers, row_sep: "").chomp
          rows.each { |fields| @stdout.puts ::CSV.generate_line(fields, row_sep: "").chomp }
        end

        def write_output_file(path, headers, rows)
          ::CSV.open(path, "w", write_headers: true, headers: headers) do |csv|
            rows.each { |fields| csv << fields }
          end
          @stdout.puts "Wrote output to #{path}"
        rescue Errno::EACCES, Errno::ENOENT => e
          @errors.cannot_write_output_file(path, e.class)
        end
      end
    end
  end
end
