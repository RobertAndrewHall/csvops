# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class SeedPrompt
          INVALID = :invalid

          def initialize(stdin:, stdout:, errors:)
            @stdin = stdin
            @stdout = stdout
            @errors = errors
          end

          def call
            @stdout.print "Random seed (optional integer): "
            raw = @stdin.gets&.strip.to_s
            return nil if raw.empty?
            return raw.to_i if /\A-?\d+\z/.match?(raw)

            @errors.invalid_seed
            INVALID
          end
        end
      end
    end
  end
end
