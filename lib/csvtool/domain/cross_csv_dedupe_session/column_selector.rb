# frozen_string_literal: true

module Csvtool
  module Domain
    module CrossCsvDedupeSession
      class ColumnSelector
        attr_reader :value

        def self.from_input(headers_present:, input:)
          if headers_present
            raise ArgumentError, "column name cannot be empty" if input.to_s.empty?

            new(value: input.to_s, headers_present: true)
          else
            raise ArgumentError, "column index must be a positive integer" unless /\A[1-9]\d*\z/.match?(input.to_s)

            new(value: input.to_i, headers_present: false)
          end
        end

        def initialize(value:, headers_present:)
          @value = value
          @headers_present = !!headers_present
        end

        def headers_present?
          @headers_present
        end

        def index?
          !@headers_present
        end
      end
    end
  end
end
