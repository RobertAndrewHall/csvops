# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/infrastructure/csv/header_reader"

module Csvtool
  module Application
    module UseCases
      class RunRowRangeShell
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
          @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
          @header_reader = Infrastructure::CSV::HeaderReader.new
        end

        def call
          file_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          return @errors.file_not_found(file_path) unless File.file?(file_path)

          col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if col_sep.nil?

          @stdout.print "Start row (1-based, inclusive): "
          start_row_input = @stdin.gets&.strip.to_s
          @stdout.print "End row (1-based, inclusive): "
          end_row_input = @stdin.gets&.strip.to_s

          headers = @header_reader.call(file_path: file_path, col_sep: col_sep)
          return @errors.no_headers if headers.empty?

          start_row, end_row = parse_and_validate_range(start_row_input, end_row_input)
          return if start_row.nil?

          output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
            stdin: @stdin,
            stdout: @stdout,
            errors: @errors
          ).call
          return if output_destination.nil?

          if output_destination[:mode] == :file
            write_to_file(
              output_path: output_destination[:path],
              file_path: file_path,
              col_sep: col_sep,
              headers: headers,
              start_row: start_row,
              end_row: end_row
            )
          else
            write_to_console(
              file_path: file_path,
              col_sep: col_sep,
              headers: headers,
              start_row: start_row,
              end_row: end_row
            )
          end
        rescue CSV::MalformedCSVError
          @errors.could_not_parse_csv
        rescue Errno::EACCES
          @errors.cannot_read_file(file_path)
        end

        private

        def parse_and_validate_range(start_row_input, end_row_input)
          unless positive_integer?(start_row_input)
            @errors.invalid_start_row
            return [nil, nil]
          end
          unless positive_integer?(end_row_input)
            @errors.invalid_end_row
            return [nil, nil]
          end

          start_row = start_row_input.to_i
          end_row = end_row_input.to_i
          if end_row < start_row
            @errors.invalid_row_range_order
            return [nil, nil]
          end

          [start_row, end_row]
        end

        def positive_integer?(value)
          /\A[1-9]\d*\z/.match?(value)
        end

        def write_to_console(file_path:, col_sep:, headers:, start_row:, end_row:)
          wrote_rows = false
          row_index = 0
          CSV.foreach(file_path, headers: true, col_sep: col_sep) do |row|
            row_index += 1
            next if row_index < start_row
            break if row_index > end_row

            unless wrote_rows
              @stdout.puts CSV.generate_line(headers, row_sep: "").chomp
              wrote_rows = true
            end
            @stdout.puts CSV.generate_line(row.fields, row_sep: "").chomp
          end

          @errors.row_range_out_of_bounds(row_index) unless wrote_rows
        end

        def write_to_file(output_path:, file_path:, col_sep:, headers:, start_row:, end_row:)
          row_index = 0
          wrote_rows = false
          CSV.open(output_path, "w") do |csv|
            CSV.foreach(file_path, headers: true, col_sep: col_sep) do |row|
              row_index += 1
              next if row_index < start_row
              break if row_index > end_row

              unless wrote_rows
                csv << headers
                wrote_rows = true
              end
              csv << row.fields
            end
          end
          return @errors.row_range_out_of_bounds(row_index) unless wrote_rows

          @stdout.puts "Wrote output to #{output_path}"
        rescue Errno::EACCES, Errno::ENOENT => e
          @errors.cannot_write_output_file(output_path, e.class)
        end
      end
    end
  end
end
