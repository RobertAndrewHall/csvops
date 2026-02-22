# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/row_streamer"
require "csvtool/infrastructure/output/csv_row_console_writer"
require "csvtool/infrastructure/output/csv_row_file_writer"
require "csvtool/domain/row_session/row_range"
require "csvtool/domain/row_session/row_source"
require "csvtool/domain/row_session/row_session"
require "csvtool/domain/shared/output_destination"

module Csvtool
  module Application
    module UseCases
      class RunRowExtraction
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
          @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
          @header_reader = Infrastructure::CSV::HeaderReader.new
          @row_streamer = Infrastructure::CSV::RowStreamer.new
        end

        def call
          file_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          return @errors.file_not_found(file_path) unless File.file?(file_path)

          col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if col_sep.nil?
          source = Domain::RowSession::RowSource.new(path: file_path, separator: col_sep)

          @stdout.print "Start row (1-based, inclusive): "
          start_row_input = @stdin.gets&.strip.to_s
          @stdout.print "End row (1-based, inclusive): "
          end_row_input = @stdin.gets&.strip.to_s

          headers = @header_reader.call(file_path: source.path, col_sep: source.separator)
          return @errors.no_headers if headers.empty?

          row_range = Domain::RowSession::RowRange.from_inputs(
            start_row_input: start_row_input,
            end_row_input: end_row_input
          )
          session = Domain::RowSession::RowSession.start(source: source, row_range: row_range)

          output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
            stdin: @stdin,
            stdout: @stdout,
            errors: @errors
          ).call
          return if output_destination.nil?
          destination =
            if output_destination[:mode] == :file
              Domain::Shared::OutputDestination.file(path: output_destination[:path])
            else
              Domain::Shared::OutputDestination.console
            end
          session = session.with_output_destination(destination)

          stats =
          if session.output_destination.file?
            Infrastructure::Output::CsvRowFileWriter.new(
              stdout: @stdout,
              errors: @errors,
              row_streamer: @row_streamer
            ).call(
              output_path: session.output_destination.path,
              file_path: session.source.path,
              col_sep: session.source.separator,
              headers: headers,
              start_row: session.row_range.start_row,
              end_row: session.row_range.end_row
            )
          else
            Infrastructure::Output::CsvRowConsoleWriter.new(stdout: @stdout, row_streamer: @row_streamer).call(
              file_path: session.source.path,
              col_sep: session.source.separator,
              headers: headers,
              start_row: session.row_range.start_row,
              end_row: session.row_range.end_row
            )
          end
          return if stats.nil?

          @errors.row_range_out_of_bounds(stats[:row_count]) unless stats[:matched]
        rescue Domain::RowSession::InvalidStartRowError
          @errors.invalid_start_row
        rescue Domain::RowSession::InvalidEndRowError
          @errors.invalid_end_row
        rescue Domain::RowSession::InvalidRowRangeOrderError
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
      end
    end
  end
end
