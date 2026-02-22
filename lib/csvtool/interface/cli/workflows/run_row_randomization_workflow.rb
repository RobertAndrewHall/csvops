# frozen_string_literal: true

require "csv"
require "csvtool/application/use_cases/run_row_randomization"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/prompts/seed_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/domain/row_randomization_session/randomization_source"
require "csvtool/domain/row_randomization_session/randomization_options"
require "csvtool/domain/row_randomization_session/randomization_session"
require "csvtool/domain/shared/output_destination"

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

            session = build_session(
              file_path: file_path,
              col_sep: col_sep,
              headers_present: headers_present,
              seed: seed,
              output_destination: output_destination
            )

            unless session.output_destination.file?
              @stdout.puts
              if headers
                @stdout.puts ::CSV.generate_line(headers, row_sep: "", col_sep: session.source.separator).chomp
              end
            end
            randomize_result = @use_case.randomize(
              session: session,
              headers: headers,
              on_row: ->(fields) { @stdout.puts ::CSV.generate_line(fields, row_sep: "", col_sep: session.source.separator).chomp }
            )
            return handle_error(randomize_result) unless randomize_result.ok?

            @stdout.puts "Wrote output to #{randomize_result.data[:output_path]}" if session.output_destination.file?
          rescue ArgumentError => e
            return @errors.empty_output_path if e.message == "file output path cannot be empty"

            raise e
          end

          private

          def build_session(file_path:, col_sep:, headers_present:, seed:, output_destination:)
            source = Domain::RowRandomizationSession::RandomizationSource.new(
              path: file_path,
              separator: col_sep,
              headers_present: headers_present
            )
            options = Domain::RowRandomizationSession::RandomizationOptions.new(seed: seed)
            session = Domain::RowRandomizationSession::RandomizationSession.start(source: source, options: options)
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
