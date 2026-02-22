# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class FilePathPrompt
          DEFAULT_LABEL = "CSV file path: "

          def initialize(stdin:, stdout:)
            @stdin = stdin
            @stdout = stdout
          end

          def call(label: DEFAULT_LABEL)
            @stdout.print label
            @stdin.gets&.strip.to_s
          end
        end
      end
    end
  end
end
