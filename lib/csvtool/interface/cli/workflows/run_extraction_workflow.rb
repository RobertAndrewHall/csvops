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
require "csvtool/interface/cli/workflows/presenters/column_extraction_presenter"
require "csvtool/interface/cli/workflows/support/output_destination_mapper"
require "csvtool/interface/cli/workflows/support/result_error_handler"
require "csvtool/interface/cli/workflows/steps/workflow_step_pipeline"
require "csvtool/interface/cli/workflows/steps/extraction/collect_inputs_step"
require "csvtool/interface/cli/workflows/steps/extraction/build_preview_step"
require "csvtool/interface/cli/workflows/steps/extraction/collect_destination_step"
require "csvtool/interface/cli/workflows/steps/extraction/execute_step"

module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunExtractionWorkflow
          def initialize(stdin:, stdout:, stderr: stdout, use_case: Application::UseCases::RunExtraction.new)
            @stdin = stdin
            @stdout = stdout
            @stderr = stderr
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: @stderr)
            @session_builder = Builders::ColumnSessionBuilder.new
            @presenter = Presenters::ColumnExtractionPresenter.new(stdout: @stdout)
            @output_destination_mapper = Support::OutputDestinationMapper.new
            @result_error_handler = Support::ResultErrorHandler.new(errors: @errors)
          end

          def call
            context = {
              use_case: @use_case,
              session_builder: @session_builder,
              output_destination_mapper: @output_destination_mapper,
              presenter: @presenter,
              handle_error: method(:handle_error)
            }

            pipeline = Steps::WorkflowStepPipeline.new(steps: [
              Steps::Extraction::CollectInputsStep.new(
                file_path_prompt: Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stderr),
                separator_prompt: Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stderr, errors: @errors),
                column_selector_prompt: Interface::CLI::Prompts::ColumnSelectorPrompt.new(stdin: @stdin, stdout: @stderr, errors: @errors),
                skip_blanks_prompt: Interface::CLI::Prompts::SkipBlanksPrompt.new(stdin: @stdin, stdout: @stderr)
              ),
              Steps::Extraction::BuildPreviewStep.new(
                confirm_prompt: Interface::CLI::Prompts::ConfirmPrompt.new(stdin: @stdin, stdout: @stderr, errors: @errors)
              ),
              Steps::Extraction::CollectDestinationStep.new(
                output_destination_prompt: Interface::CLI::Prompts::OutputDestinationPrompt.new(
                  stdin: @stdin,
                  stdout: @stderr,
                  errors: @errors
                )
              ),
              Steps::Extraction::ExecuteStep.new
            ])
            pipeline.call(context)
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
