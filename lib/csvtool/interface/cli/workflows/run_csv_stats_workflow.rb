# frozen_string_literal: true

require "csvtool/interface/cli/prompts/file_path_prompt"

module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunCsvStatsWorkflow
          def initialize(stdin:, stdout:)
            @stdin = stdin
            @stdout = stdout
          end

          def call
            file_path_prompt.call(label: "CSV file path: ")
            @stdout.puts "Stats workflow ready."
            nil
          end

          private

          def file_path_prompt
            @file_path_prompt ||= Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout)
          end
        end
      end
    end
  end
end
