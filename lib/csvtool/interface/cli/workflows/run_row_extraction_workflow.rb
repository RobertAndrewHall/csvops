# frozen_string_literal: true

require "csvtool/application/use_cases/run_row_extraction"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/interface/cli/workflows/builders/row_extraction_session_builder"
require "csvtool/interface/cli/workflows/presenters/row_extraction_presenter"
require "csvtool/interface/cli/workflows/support/output_destination_mapper"
require "csvtool/interface/cli/workflows/support/result_error_handler"
require "csvtool/interface/cli/workflows/steps/workflow_step_pipeline"
require "csvtool/interface/cli/workflows/steps/row_extraction/collect_source_step"
require "csvtool/interface/cli/workflows/steps/row_extraction/read_headers_step"
require "csvtool/interface/cli/workflows/steps/row_extraction/collect_range_step"
require "csvtool/interface/cli/workflows/steps/row_extraction/collect_destination_step"
require "csvtool/interface/cli/workflows/steps/row_extraction/execute_step"
require "csvtool/domain/row_session/row_range"
module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunRowExtractionWorkflow
          def initialize(stdin:, stdout:, stderr: stdout, use_case: Application::UseCases::RunRowExtraction.new)
            @stdin = stdin
            @stdout = stdout
            @stderr = stderr
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: @stderr)
            @session_builder = Builders::RowExtractionSessionBuilder.new
            @output_destination_mapper = Support::OutputDestinationMapper.new
            @result_error_handler = Support::ResultErrorHandler.new(errors: @errors)
          end

          def call
            context = {
              use_case: @use_case,
              session_builder: @session_builder,
              output_destination_mapper: @output_destination_mapper,
              handle_error: method(:handle_error)
            }

            pipeline = Steps::WorkflowStepPipeline.new(steps: [
              Steps::RowExtraction::CollectSourceStep.new(
                file_path_prompt: Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stderr),
                separator_prompt: Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stderr, errors: @errors)
              ),
              Steps::RowExtraction::ReadHeadersStep.new,
              Steps::RowExtraction::CollectRangeStep.new(stdin: @stdin, stdout: @stderr),
              Steps::RowExtraction::CollectDestinationStep.new(
                output_destination_prompt: Interface::CLI::Prompts::OutputDestinationPrompt.new(
                  stdin: @stdin,
                  stdout: @stderr,
                  errors: @errors
                )
              ),
              Steps::RowExtraction::ExecuteStep.new(stdout: @stdout, errors: @errors)
            ])
            pipeline.call(context)
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

          def handle_error(result)
            @result_error_handler.call(result, {
              file_not_found: ->(r, errors) { errors.file_not_found(r.data[:path]) },
              no_headers: ->(_r, errors) { errors.no_headers },
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
