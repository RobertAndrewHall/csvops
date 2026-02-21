# frozen_string_literal: true

module Csvtool
  module Domain
    module ExtractionSession
      class Separator
        attr_reader :value

        def initialize(value)
          raise ArgumentError, "separator cannot be empty" if value.to_s.empty?

          @value = value
        end
      end
    end
  end
end
