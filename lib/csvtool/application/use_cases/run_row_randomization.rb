# frozen_string_literal: true

require "csvtool/interface/cli/prompts/file_path_prompt"

module Csvtool
  module Application
    module UseCases
      class RunRowRandomization
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
        end

        def call
          file_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          return if file_path.empty?

          @stdout.puts "Randomize rows workflow selected for: #{file_path}"
          @stdout.puts "Row randomization implementation is next."
        end
      end
    end
  end
end
