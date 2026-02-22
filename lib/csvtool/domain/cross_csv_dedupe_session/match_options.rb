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

        def normalize(value)
          normalized = trim_whitespace? ? value.to_s.strip : value.to_s
          case_insensitive? ? normalized.downcase : normalized
        end
      end
    end
  end
end
