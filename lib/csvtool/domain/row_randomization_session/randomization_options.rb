# frozen_string_literal: true

module Csvtool
  module Domain
    module RowRandomizationSession
      class RandomizationOptions
        attr_reader :seed

        def initialize(seed:)
          raise ArgumentError, "seed must be an integer or nil" unless seed.nil? || seed.is_a?(Integer)

          @seed = seed
        end
      end
    end
  end
end
