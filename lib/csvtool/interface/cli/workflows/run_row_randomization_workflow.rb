# frozen_string_literal: true

require "csvtool/application/use_cases/run_row_randomization"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/prompts/seed_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/interface/cli/workflows/builders/row_randomization_session_builder"
require "csvtool/interface/cli/workflows/presenters/row_randomization_presenter"
require "csvtool/interface/cli/workflows/support/output_destination_mapper"
require "csvtool/interface/cli/workflows/support/result_error_handler"
require "csvtool/interface/cli/workflows/steps/workflow_step_pipeline"
require "csvtool/interface/cli/workflows/steps/row_randomization/collect_inputs_step"
require "csvtool/interface/cli/workflows/steps/row_randomization/collect_destination_step"
require "csvtool/interface/cli/workflows/steps/row_randomization/execute_step"
module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunRowRandomizationWorkflow
          def initialize(stdin:, stdout:, use_case: Application::UseCases::RunRowRandomization.new)
            @stdin = stdin
            @stdout = stdout
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
            @session_builder = Builders::RowRandomizationSessionBuilder.new
            @output_destination_mapper = Support::OutputDestinationMapper.new
            @result_error_handler = Support::ResultErrorHandler.new(errors: @errors)
          end

          def call
            context = {
              use_case: @use_case,
              session_builder: @session_builder,
              output_destination_mapper: @output_destination_mapper,
              presenter_factory: ->(headers:, col_sep:) { Presenters::RowRandomizationPresenter.new(stdout: @stdout, headers: headers, col_sep: col_sep) },
              handle_error: method(:handle_error)
            }

            pipeline = Steps::WorkflowStepPipeline.new(steps: [
              Steps::RowRandomization::CollectInputsStep.new(
                file_path_prompt: Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout),
                separator_prompt: Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors),
                headers_present_prompt: Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: @stdin, stdout: @stdout),
                seed_prompt: Interface::CLI::Prompts::SeedPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors)
              ),
              Steps::RowRandomization::CollectDestinationStep.new(
                output_destination_prompt: Interface::CLI::Prompts::OutputDestinationPrompt.new(
                  stdin: @stdin,
                  stdout: @stdout,
                  errors: @errors
                )
              ),
              Steps::RowRandomization::ExecuteStep.new
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
