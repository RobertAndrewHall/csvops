# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class ConfirmPrompt
          def initialize(stdin:, stdout:, errors:)
            @stdin = stdin
            @stdout = stdout
            @errors = errors
          end

          def call(preview_values)
            @stdout.puts "Preview (first #{preview_values.length} values):"
            preview_values.each { |value| @stdout.puts value }
            @stdout.print "Print all values? [y/N]: "

            answer = @stdin.gets&.strip.to_s.downcase
            return true if %w[y yes].include?(answer)

            @errors.canceled
            false
          end
        end
      end
    end
  end
end
