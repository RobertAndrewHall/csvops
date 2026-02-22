# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class ChunkSizePrompt
          def initialize(stdin:, stdout:)
            @stdin = stdin
            @stdout = stdout
          end

          def call
            @stdout.print "Rows per chunk: "
            @stdin.gets&.strip.to_s
          end
        end
      end
    end
  end
end
