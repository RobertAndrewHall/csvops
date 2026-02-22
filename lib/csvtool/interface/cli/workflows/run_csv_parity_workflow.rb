# frozen_string_literal: true

require "csvtool/application/use_cases/run_csv_parity"
require "csvtool/interface/cli/prompts/file_path_prompt"

module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunCsvParityWorkflow
          def initialize(stdin:, stdout:, use_case: Application::UseCases::RunCsvParity.new)
            @stdin = stdin
            @stdout = stdout
            @use_case = use_case
          end

          def call
            file_path_prompt = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout)
            left_path = file_path_prompt.call(label: "Left CSV file path: ")
            right_path = file_path_prompt.call(label: "Right CSV file path: ")

            @use_case.call(left_path: left_path, right_path: right_path)
            @stdout.puts "Parity validation workflow shell complete."
            nil
          end
        end
      end
    end
  end
end
