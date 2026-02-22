# frozen_string_literal: true

require "csvtool/application/use_cases/run_extraction"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/column_selector_prompt"
require "csvtool/interface/cli/prompts/skip_blanks_prompt"
require "csvtool/interface/cli/prompts/confirm_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/interface/cli/workflows/builders/column_session_builder"
require "csvtool/interface/cli/workflows/support/output_destination_mapper"
require "csvtool/interface/cli/workflows/support/result_error_handler"
require "csvtool/domain/column_session/separator"
require "csvtool/domain/column_session/csv_source"
require "csvtool/domain/column_session/column_selection"
require "csvtool/domain/column_session/extraction_options"
require "csvtool/domain/column_session/extraction_value"
require "csvtool/domain/column_session/preview"
require "csvtool/domain/column_session/column_session"

module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunExtractionWorkflow
          def initialize(stdin:, stdout:, use_case: Application::UseCases::RunExtraction.new)
            @stdin = stdin
            @stdout = stdout
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
            @session_builder = Builders::ColumnSessionBuilder.new
            @output_destination_mapper = Support::OutputDestinationMapper.new
            @result_error_handler = Support::ResultErrorHandler.new(errors: @errors)
          end

          def call
            file_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
            col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
            return if col_sep.nil?

            header_result = @use_case.read_headers(file_path: file_path, col_sep: col_sep)
            return handle_error(header_result) unless header_result.ok?
            headers = header_result.data[:headers]

            column_name = Interface::CLI::Prompts::ColumnSelectorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call(headers)
            return if column_name.nil?
            skip_blanks = Interface::CLI::Prompts::SkipBlanksPrompt.new(stdin: @stdin, stdout: @stdout).call

            session = @session_builder.call(file_path: file_path, col_sep: col_sep, column_name: column_name, skip_blanks: skip_blanks)
            preview_result = @use_case.preview(session: session)
            return handle_error(preview_result) unless preview_result.ok?
            preview = Domain::ColumnSession::Preview.new(
              values: preview_result.data[:preview_values].map { |value| Domain::ColumnSession::ExtractionValue.new(value) }
            )
            session = session.with_preview(preview)

            confirmed = Interface::CLI::Prompts::ConfirmPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call(session.preview.to_strings)
            return unless confirmed
            session = session.confirm!

            output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
              stdin: @stdin,
              stdout: @stdout,
              errors: @errors
            ).call
            return if output_destination.nil?
            session = session.with_output_destination(@output_destination_mapper.call(output_destination))

            extract_result = @use_case.extract(session: session, on_value: ->(value) { @stdout.puts value })
            return handle_error(extract_result) unless extract_result.ok?

            @stdout.puts "Wrote output to #{extract_result.data[:output_path]}" if session.output_destination.file?
          rescue ArgumentError => e
            return @errors.empty_output_path if e.message == "file output path cannot be empty"

            raise e
          end

          private

          def handle_error(result)
            @result_error_handler.call(result, {
              file_not_found: ->(r, errors) { errors.file_not_found(r.data[:path]) },
              no_headers: ->(_r, errors) { errors.no_headers },
              column_not_found: ->(_r, errors) { errors.column_not_found },
              could_not_parse_csv: ->(_r, errors) { errors.could_not_parse_csv },
              cannot_read_file: ->(r, errors) { errors.cannot_read_file(r.data[:path]) },
              cannot_write_output_file: ->(r, errors) { errors.cannot_write_output_file(r.data[:path], r.data[:error_class]) }
            })
          end
        end
      end
    end
  end
end
