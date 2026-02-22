# frozen_string_literal: true

require "csvtool/application/use_cases/run_csv_split"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/prompts/chunk_size_prompt"
require "csvtool/interface/cli/prompts/yes_no_prompt"
require "csvtool/interface/cli/prompts/split_output_prompt"
require "csvtool/interface/cli/workflows/builders/csv_split_session_builder"
require "csvtool/interface/cli/workflows/presenters/csv_split_presenter"
require "csvtool/interface/cli/workflows/support/result_error_handler"
require "csvtool/interface/cli/workflows/steps/workflow_step_pipeline"
require "csvtool/interface/cli/workflows/steps/csv_split/collect_inputs_step"
require "csvtool/interface/cli/workflows/steps/csv_split/collect_output_step"
require "csvtool/interface/cli/workflows/steps/csv_split/build_session_step"
require "csvtool/interface/cli/workflows/steps/csv_split/execute_step"

module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunCsvSplitWorkflow
          def initialize(stdin:, stdout:, use_case: Application::UseCases::RunCsvSplit.new)
            @stdin = stdin
            @stdout = stdout
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
            @session_builder = Builders::CsvSplitSessionBuilder.new
            @presenter = Presenters::CsvSplitPresenter.new(stdout: stdout)
            @result_error_handler = Support::ResultErrorHandler.new(errors: @errors)
          end

          def call
            context = {
              use_case: @use_case,
              session_builder: @session_builder,
              presenter: @presenter,
              handle_error: method(:handle_error)
            }
            pipeline = Steps::WorkflowStepPipeline.new(steps: [
              Steps::CsvSplit::CollectInputsStep.new(
                file_path_prompt: Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout),
                separator_prompt: Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors),
                headers_present_prompt: Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: @stdin, stdout: @stdout),
                chunk_size_prompt: Interface::CLI::Prompts::ChunkSizePrompt.new(stdin: @stdin, stdout: @stdout)
              ),
              Steps::CsvSplit::CollectOutputStep.new(
                split_output_prompt: Interface::CLI::Prompts::SplitOutputPrompt.new(
                  stdin: @stdin,
                  stdout: @stdout,
                  yes_no_prompt: Interface::CLI::Prompts::YesNoPrompt.new(stdin: @stdin, stdout: @stdout)
                )
              ),
              Steps::CsvSplit::BuildSessionStep.new,
              Steps::CsvSplit::ExecuteStep.new
            ])
            pipeline.call(context)
            nil
          end

          private

          def handle_error(result)
            @result_error_handler.call(result, {
              file_not_found: ->(r, errors) { errors.file_not_found(r.data[:path]) },
              no_headers: ->(_r, errors) { errors.no_headers },
              could_not_parse_csv: ->(_r, errors) { errors.could_not_parse_csv },
              cannot_read_file: ->(r, errors) { errors.cannot_read_file(r.data[:path]) },
              cannot_write_output_file: ->(r, errors) { errors.cannot_write_output_file(r.data[:path], r.data[:error_class]) },
              output_file_exists: ->(r, errors) { errors.output_file_exists(r.data[:path]) }
            })
          end
        end
      end
    end
  end
end
