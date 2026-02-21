# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class HeadersPresentPrompt
          def initialize(stdin:, stdout:)
            @stdin = stdin
            @stdout = stdout
          end

          def call
            @stdout.print "Headers present? [Y/n]: "
            answer = @stdin.gets&.strip.to_s.downcase
            !%w[n no].include?(answer)
          end
        end
      end
    end
  end
end
