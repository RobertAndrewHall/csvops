# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class YesNoPrompt
          def initialize(stdin:, stdout:)
            @stdin = stdin
            @stdout = stdout
          end

          def call(label:, default:)
            @stdout.print label
            answer = @stdin.gets&.strip.to_s.downcase
            return default if answer.empty?
            return true if %w[y yes].include?(answer)
            return false if %w[n no].include?(answer)

            default
          end
        end
      end
    end
  end
end
