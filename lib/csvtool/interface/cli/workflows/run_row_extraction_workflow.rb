# frozen_string_literal: true

require "csv"
require "csvtool/application/use_cases/run_row_extraction"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/domain/row_session/row_range"
require "csvtool/domain/row_session/row_source"
require "csvtool/domain/row_session/row_session"
require "csvtool/domain/shared/output_destination"

module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunRowExtractionWorkflow
          def initialize(stdin:, stdout:, use_case: Application::UseCases::RunRowExtraction.new)
            @stdin = stdin
            @stdout = stdout
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
          end

          def call
            file_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
            col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
            return if col_sep.nil?

            header_result = @use_case.read_headers(file_path: file_path, col_sep: col_sep)
            return handle_error(header_result) unless header_result.ok?
            headers = header_result.data[:headers]

            @stdout.print "Start row (1-based, inclusive): "
            start_row_input = @stdin.gets&.strip.to_s
            @stdout.print "End row (1-based, inclusive): "
            end_row_input = @stdin.gets&.strip.to_s
            row_range = Domain::RowSession::RowRange.from_inputs(
              start_row_input: start_row_input,
              end_row_input: end_row_input
            )

            output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
              stdin: @stdin,
              stdout: @stdout,
              errors: @errors
            ).call
            return if output_destination.nil?

            session = build_session(
              file_path: file_path,
              col_sep: col_sep,
              row_range: row_range,
              output_destination: output_destination
            )

            wrote_header = false
            extract_result = @use_case.extract(
              session: session,
              headers: headers,
              on_row: lambda do |fields|
                unless wrote_header
                  @stdout.puts ::CSV.generate_line(headers, row_sep: "").chomp
                  wrote_header = true
                end
                @stdout.puts ::CSV.generate_line(fields, row_sep: "").chomp
              end
            )
            return handle_error(extract_result) unless extract_result.ok?

            @stdout.puts "Wrote output to #{extract_result.data[:output_path]}" if extract_result.data[:wrote_rows]
            return if extract_result.data[:matched]

            @errors.row_range_out_of_bounds(extract_result.data[:row_count])
          rescue Domain::RowSession::InvalidStartRowError
            @errors.invalid_start_row
          rescue Domain::RowSession::InvalidEndRowError
            @errors.invalid_end_row
          rescue Domain::RowSession::InvalidRowRangeOrderError
            @errors.invalid_row_range_order
          rescue ArgumentError => e
            return @errors.empty_output_path if e.message == "file output path cannot be empty"

            raise e
          end

          private

          def build_session(file_path:, col_sep:, row_range:, output_destination:)
            source = Domain::RowSession::RowSource.new(path: file_path, separator: col_sep)
            session = Domain::RowSession::RowSession.start(source: source, row_range: row_range)
            session.with_output_destination(
              if output_destination[:mode] == :file
                Domain::Shared::OutputDestination.file(path: output_destination[:path])
              else
                Domain::Shared::OutputDestination.console
              end
            )
          end

          def handle_error(result)
            case result.error
            when :file_not_found
              @errors.file_not_found(result.data[:path])
            when :no_headers
              @errors.no_headers
            when :could_not_parse_csv
              @errors.could_not_parse_csv
            when :cannot_read_file
              @errors.cannot_read_file(result.data[:path])
            when :cannot_write_output_file
              @errors.cannot_write_output_file(result.data[:path], result.data[:error_class])
            end
          end
        end
      end
    end
  end
end
