# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class OutputDestinationPrompt
          def initialize(stdin:, stdout:, errors:)
            @stdin = stdin
            @stdout = stdout
            @errors = errors
          end

          def call
            @stdout.puts "Output destination:"
            @stdout.puts "1. console"
            @stdout.puts "2. file"
            @stdout.print "Output destination [1]: "
            choice = @stdin.gets&.strip.to_s

            case choice
            when "", "1"
              { mode: :console }
            when "2"
              @stdout.print "Output file path: "
              output_path = @stdin.gets&.strip.to_s
              return { mode: :file, path: output_path } unless output_path.empty?

              @errors.empty_output_path
              nil
            else
              @errors.invalid_output_destination
              nil
            end
          end
        end
      end
    end
  end
end
