# frozen_string_literal: true

require "csvtool/application/use_cases/run_cross_csv_dedupe"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/prompts/yes_no_prompt"
require "csvtool/interface/cli/prompts/dedupe_key_selector_prompt"
require "csvtool/interface/cli/workflows/builders/cross_csv_dedupe_session_builder"
require "csvtool/interface/cli/workflows/presenters/cross_csv_dedupe_presenter"
require "csvtool/interface/cli/workflows/support/output_destination_mapper"
require "csvtool/interface/cli/workflows/support/result_error_handler"
require "csvtool/interface/cli/workflows/steps/workflow_step_pipeline"
require "csvtool/interface/cli/workflows/steps/cross_csv_dedupe/collect_profiles_step"
require "csvtool/interface/cli/workflows/steps/cross_csv_dedupe/collect_options_step"
require "csvtool/interface/cli/workflows/steps/cross_csv_dedupe/execute_step"
require "csvtool/domain/cross_csv_dedupe_session/csv_profile"
require "csvtool/domain/cross_csv_dedupe_session/column_selector"
module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunCrossCsvDedupeWorkflow
          def initialize(stdin:, stdout:, stderr: stdout, use_case: Application::UseCases::RunCrossCsvDedupe.new)
            @stdin = stdin
            @stdout = stdout
            @stderr = stderr
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: @stderr)
            @session_builder = Builders::CrossCsvDedupeSessionBuilder.new
            @output_destination_mapper = Support::OutputDestinationMapper.new
            @result_error_handler = Support::ResultErrorHandler.new(errors: @errors)
          end

          def call
            context = {
              use_case: @use_case,
              session_builder: @session_builder,
              output_destination_mapper: @output_destination_mapper,
              presenter_factory: ->(col_sep:) { Presenters::CrossCsvDedupePresenter.new(stdout: @stdout, col_sep: col_sep) },
              handle_error: method(:handle_error)
            }

            pipeline = Steps::WorkflowStepPipeline.new(steps: [
              Steps::CrossCsvDedupe::CollectProfilesStep.new(
                file_path_prompt: Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stderr),
                separator_prompt: Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stderr, errors: @errors),
                headers_present_prompt: Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: @stdin, stdout: @stderr),
                errors: @errors
              ),
              Steps::CrossCsvDedupe::CollectOptionsStep.new(
                selector_prompt: Interface::CLI::Prompts::DedupeKeySelectorPrompt.new(stdin: @stdin, stdout: @stderr),
                yes_no_prompt: Interface::CLI::Prompts::YesNoPrompt.new(stdin: @stdin, stdout: @stderr),
                output_destination_prompt: Interface::CLI::Prompts::OutputDestinationPrompt.new(
                  stdin: @stdin,
                  stdout: @stderr,
                  errors: @errors
                ),
                errors: @errors
              ),
              Steps::CrossCsvDedupe::ExecuteStep.new
            ])
            pipeline.call(context)
          rescue ArgumentError => e
            return @errors.empty_output_path if e.message == "file output path cannot be empty"

            raise e
          end

          private

          def handle_error(result)
            @result_error_handler.call(result, {
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
