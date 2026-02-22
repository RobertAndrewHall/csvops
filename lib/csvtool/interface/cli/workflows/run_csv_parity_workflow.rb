# frozen_string_literal: true

require "csvtool/application/use_cases/run_csv_parity"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/workflows/builders/csv_parity_session_builder"
require "csvtool/interface/cli/workflows/presenters/csv_parity_presenter"
require "csvtool/interface/cli/workflows/support/result_error_handler"

module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunCsvParityWorkflow
          def initialize(stdin:, stdout:, use_case: Application::UseCases::RunCsvParity.new)
            @stdin = stdin
            @stdout = stdout
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
            @session_builder = Builders::CsvParitySessionBuilder.new
            @presenter = Presenters::CsvParityPresenter.new(stdout: stdout)
            @result_error_handler = Support::ResultErrorHandler.new(errors: @errors)
          end

          def call
            file_path_prompt = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout)
            left_path = file_path_prompt.call(label: "Left CSV file path: ")
            right_path = file_path_prompt.call(label: "Right CSV file path: ")
            separator_prompt = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors)
            col_sep = separator_prompt.call
            return nil if col_sep.nil?

            headers_present = Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: @stdin, stdout: @stdout).call

            session = @session_builder.call(
              left_path: left_path,
              right_path: right_path,
              col_sep: col_sep,
              headers_present: headers_present
            )
            result = @use_case.call(session: session)
            return handle_error(result) unless result.ok?

            @presenter.print_summary(result.data)
            nil
          end

          private

          def handle_error(result)
            @result_error_handler.call(result, {
              file_not_found: ->(r, errors) { errors.file_not_found(r.data[:path]) },
              could_not_parse_csv: ->(_r, errors) { errors.could_not_parse_csv },
              cannot_read_file: ->(r, errors) { errors.cannot_read_file(r.data[:path]) },
              no_headers: ->(_r, errors) { errors.no_headers },
              header_mismatch: ->(_r, errors) { errors.header_mismatch }
            })
          end
        end
      end
    end
  end
end
