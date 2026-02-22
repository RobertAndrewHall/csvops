# frozen_string_literal: true

require "csvtool/application/use_cases/run_csv_stats"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/workflows/builders/csv_stats_session_builder"
require "csvtool/interface/cli/workflows/presenters/csv_stats_presenter"
require "csvtool/interface/cli/workflows/support/result_error_handler"
require "csvtool/interface/cli/workflows/steps/workflow_step_pipeline"
require "csvtool/interface/cli/workflows/steps/csv_stats/collect_inputs_step"
require "csvtool/interface/cli/workflows/steps/csv_stats/build_session_step"
require "csvtool/interface/cli/workflows/steps/csv_stats/execute_step"

module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunCsvStatsWorkflow
          def initialize(stdin:, stdout:, use_case: Application::UseCases::RunCsvStats.new)
            @stdin = stdin
            @stdout = stdout
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
            @session_builder = Builders::CsvStatsSessionBuilder.new
            @presenter = Presenters::CsvStatsPresenter.new(stdout: stdout)
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
              Steps::CsvStats::CollectInputsStep.new(
                file_path_prompt: Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout),
                separator_prompt: Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors),
                headers_present_prompt: Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: @stdin, stdout: @stdout)
              ),
              Steps::CsvStats::BuildSessionStep.new,
              Steps::CsvStats::ExecuteStep.new
            ])
            pipeline.call(context)
            nil
          end

          private

          def handle_error(result)
            @result_error_handler.call(result, {
              file_not_found: ->(r, errors) { errors.file_not_found(r.data[:path]) },
              could_not_parse_csv: ->(_r, errors) { errors.could_not_parse_csv },
              cannot_read_file: ->(r, errors) { errors.cannot_read_file(r.data[:path]) }
            })
          end
        end
      end
    end
  end
end
