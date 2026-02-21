# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class FilePathPrompt
          def initialize(stdin:, stdout:)
            @stdin = stdin
            @stdout = stdout
          end

          def call
            @stdout.print "CSV file path: "
            @stdin.gets&.strip.to_s
          end
        end
      end
    end
  end
end
