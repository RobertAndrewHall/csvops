# frozen_string_literal: true

require "csvtool/interface/cli/prompts/file_path_prompt"

module Csvtool
  module Application
    module UseCases
      class RunCrossCsvDedupe
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
        end

        def call
          source_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          @stdout.print "Reference CSV file path: "
          reference_path = @stdin.gets&.strip.to_s
          @stdout.print "Source key column name: "
          source_column = @stdin.gets&.strip.to_s
          @stdout.print "Reference key column name: "
          reference_column = @stdin.gets&.strip.to_s

          return if source_path.empty? || reference_path.empty? || source_column.empty? || reference_column.empty?

          @stdout.puts "Dedupe workflow selected."
        end
      end
    end
  end
end
