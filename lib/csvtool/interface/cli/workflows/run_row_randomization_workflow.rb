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
            file_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
            col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
            return if col_sep.nil?

            headers_present = Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: @stdin, stdout: @stdout).call
            header_result = @use_case.read_headers(file_path: file_path, col_sep: col_sep, headers_present: headers_present)
            return handle_error(header_result) unless header_result.ok?
            headers = header_result.data[:headers]

            seed = Interface::CLI::Prompts::SeedPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
            return if seed == Interface::CLI::Prompts::SeedPrompt::INVALID

            output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
              stdin: @stdin,
              stdout: @stdout,
              errors: @errors
            ).call
            return if output_destination.nil?

            session = @session_builder.call(
              file_path: file_path,
              col_sep: col_sep,
              headers_present: headers_present,
              seed: seed,
              destination: @output_destination_mapper.call(output_destination)
            )

            presenter = Presenters::RowRandomizationPresenter.new(
              stdout: @stdout,
              headers: headers,
              col_sep: session.source.separator
            )
            presenter.print_console_start unless session.output_destination.file?
            randomize_result = @use_case.randomize(
              session: session,
              headers: headers,
              on_row: ->(fields) { presenter.print_row(fields) }
            )
            return handle_error(randomize_result) unless randomize_result.ok?

            presenter.print_file_written(randomize_result.data[:output_path]) if session.output_destination.file?
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
