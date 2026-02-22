# frozen_string_literal: true

module Csvtool
  module Domain
    module CrossCsvDedupeSession
      class KeyMapping
        attr_reader :source_selector, :reference_selector

        def initialize(source_selector:, reference_selector:)
          @source_selector = source_selector
          @reference_selector = reference_selector
        end
      end
    end
  end
end
