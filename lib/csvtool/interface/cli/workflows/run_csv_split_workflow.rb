# frozen_string_literal: true

require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/chunk_size_prompt"

module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunCsvSplitWorkflow
          def initialize(stdin:, stdout:)
            @stdin = stdin
            @stdout = stdout
          end

          def call
            file_path_prompt.call(label: "Source CSV file path: ")
            chunk_size_prompt.call
            @stdout.puts "Split workflow ready."
            nil
          end

          private

          def file_path_prompt
            @file_path_prompt ||= Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout)
          end

          def chunk_size_prompt
            @chunk_size_prompt ||= Interface::CLI::Prompts::ChunkSizePrompt.new(stdin: @stdin, stdout: @stdout)
          end
        end
      end
    end
  end
end
