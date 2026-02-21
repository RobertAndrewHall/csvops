# frozen_string_literal: true

module Csvtool
  module Domain
    module ColumnSession
      class ExtractionValue
        attr_reader :value

        def initialize(value)
          @value = value.to_s
        end
      end
    end
  end
end
