# frozen_string_literal: true

module Csvtool
  module Domain
    module ExtractionSession
      class Preview
        attr_reader :values

        def initialize(values:)
          @values = values
        end

        def size
          @values.size
        end

        def to_strings
          @values.map(&:value)
        end
      end
    end
  end
end
