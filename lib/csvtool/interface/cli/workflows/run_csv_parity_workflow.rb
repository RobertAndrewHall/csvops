# frozen_string_literal: true

require "csvtool/application/use_cases/run_csv_parity"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/workflows/builders/csv_parity_session_builder"

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

            print_summary(result.data)
            nil
          end

          private

          def print_summary(data)
            @stdout.puts(data[:match] ? "MATCH" : "MISMATCH")
            @stdout.puts "Summary: left_rows=#{data[:left_rows]} right_rows=#{data[:right_rows]} " \
                         "left_only=#{data[:left_only_count]} right_only=#{data[:right_only_count]}"
            return if data[:match]

            print_examples("Left-only examples", data[:left_only_examples])
            print_examples("Right-only examples", data[:right_only_examples])
          end

          def print_examples(label, examples)
            return if examples.nil? || examples.empty?

            @stdout.puts "#{label}:"
            examples.each do |example|
              @stdout.puts "  #{example[:row]} (count +#{example[:count_delta]})"
            end
          end

          def handle_error(result)
            case result.error
            when :file_not_found
              @errors.file_not_found(result.data[:path])
            when :could_not_parse_csv
              @errors.could_not_parse_csv
            when :cannot_read_file
              @errors.cannot_read_file(result.data[:path])
            when :no_headers
              @errors.no_headers
            when :header_mismatch
              @errors.header_mismatch
            else
              @stdout.puts "Unexpected parity validation failure."
            end
          end
        end
      end
    end
  end
end
