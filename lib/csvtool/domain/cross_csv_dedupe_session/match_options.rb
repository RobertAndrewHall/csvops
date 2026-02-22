# frozen_string_literal: true

module Csvtool
  module Domain
    module CrossCsvDedupeSession
      class MatchOptions
        attr_reader :trim_whitespace, :case_insensitive

        def initialize(trim_whitespace:, case_insensitive:)
          @trim_whitespace = !!trim_whitespace
          @case_insensitive = !!case_insensitive
        end

        def trim_whitespace?
          @trim_whitespace
        end

        def case_insensitive?
          @case_insensitive
        end
      end
    end
  end
end
