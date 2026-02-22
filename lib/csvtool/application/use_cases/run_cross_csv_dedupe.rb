# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/cross_csv_deduper"

module Csvtool
  module Application
    module UseCases
      class RunCrossCsvDedupe
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
          @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
          @header_reader = Infrastructure::CSV::HeaderReader.new
          @deduper = Infrastructure::CSV::CrossCsvDeduper.new
        end

        def call
          source_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          return @errors.file_not_found(source_path) unless File.file?(source_path)

          @stdout.print "Reference CSV file path: "
          reference_path = @stdin.gets&.strip.to_s
          return @errors.file_not_found(reference_path) unless File.file?(reference_path)

          @stdout.print "Source key column name: "
          source_column = @stdin.gets&.strip.to_s
          @stdout.print "Reference key column name: "
          reference_column = @stdin.gets&.strip.to_s

          return if source_path.empty? || reference_path.empty? || source_column.empty? || reference_column.empty?

          source_headers = @header_reader.call(file_path: source_path, col_sep: ",")
          return @errors.no_headers if source_headers.empty?
          return @errors.column_not_found unless source_headers.include?(source_column)

          reference_headers = @header_reader.call(file_path: reference_path, col_sep: ",")
          return @errors.no_headers if reference_headers.empty?
          return @errors.column_not_found unless reference_headers.include?(reference_column)

          result = @deduper.call(
            source_path: source_path,
            reference_path: reference_path,
            source_column: source_column,
            reference_column: reference_column,
            col_sep: ","
          )

          output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
            stdin: @stdin,
            stdout: @stdout,
            errors: @errors
          ).call
          return if output_destination.nil?

          if output_destination[:mode] == :file
            write_output_file(output_destination[:path], result[:headers], result[:kept_rows])
          else
            print_to_console(result[:headers], result[:kept_rows])
          end
          @stdout.puts "Summary: source_rows=#{result[:source_rows]} removed_rows=#{result[:removed_rows]} kept_rows=#{result[:kept_rows_count]}"
        rescue CSV::MalformedCSVError
          @errors.could_not_parse_csv
        rescue Errno::EACCES
          @errors.cannot_read_file(source_path)
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
