# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/domain/row_range_session/row_range"
require "csvtool/domain/row_range_session/row_source"
require "csvtool/domain/row_range_session/output_destination"
require "csvtool/domain/row_range_session/row_range_session"

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
          source = Domain::RowRangeSession::RowSource.new(path: file_path, separator: col_sep)

          @stdout.print "Start row (1-based, inclusive): "
          start_row_input = @stdin.gets&.strip.to_s
          @stdout.print "End row (1-based, inclusive): "
          end_row_input = @stdin.gets&.strip.to_s

          headers = @header_reader.call(file_path: source.path, col_sep: source.separator)
          return @errors.no_headers if headers.empty?

          row_range = Domain::RowRangeSession::RowRange.from_inputs(
            start_row_input: start_row_input,
            end_row_input: end_row_input
          )
          session = Domain::RowRangeSession::RowRangeSession.start(source: source, row_range: row_range)

          output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
            stdin: @stdin,
            stdout: @stdout,
            errors: @errors
          ).call
          return if output_destination.nil?
          destination =
            if output_destination[:mode] == :file
              Domain::RowRangeSession::OutputDestination.file(path: output_destination[:path])
            else
              Domain::RowRangeSession::OutputDestination.console
            end
          session = session.with_output_destination(destination)

          if session.output_destination.file?
            write_to_file(
              output_path: session.output_destination.path,
              file_path: session.source.path,
              col_sep: session.source.separator,
              headers: headers,
              start_row: session.row_range.start_row,
              end_row: session.row_range.end_row
            )
          else
            write_to_console(
              file_path: session.source.path,
              col_sep: session.source.separator,
              headers: headers,
              start_row: session.row_range.start_row,
              end_row: session.row_range.end_row
            )
          end
        rescue Domain::RowRangeSession::InvalidStartRowError
          @errors.invalid_start_row
        rescue Domain::RowRangeSession::InvalidEndRowError
          @errors.invalid_end_row
        rescue Domain::RowRangeSession::InvalidRowRangeOrderError
          @errors.invalid_row_range_order
        rescue ArgumentError => e
          return @errors.empty_output_path if e.message == "file output path cannot be empty"

          raise e
        rescue CSV::MalformedCSVError
          @errors.could_not_parse_csv
        rescue Errno::EACCES
          @errors.cannot_read_file(file_path)
        end
        
        private

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
