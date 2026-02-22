# frozen_string_literal: true

require "csvtool/domain/cross_csv_dedupe_session/column_selector"

module Csvtool
  module Domain
    module CrossCsvDedupeSession
      class KeyMapping
        attr_reader :source_selector, :reference_selector

        def initialize(source_selector:, reference_selector:)
          unless source_selector.is_a?(ColumnSelector) && reference_selector.is_a?(ColumnSelector)
            raise ArgumentError, "selectors must be ColumnSelector"
          end

          @source_selector = source_selector
          @reference_selector = reference_selector
        end
      end
    end
  end
end
