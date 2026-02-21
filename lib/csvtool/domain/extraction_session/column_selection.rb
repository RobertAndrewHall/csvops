# frozen_string_literal: true

module Csvtool
  module Domain
    module ExtractionSession
      class ColumnSelection
        attr_reader :name

        def initialize(name:)
          raise ArgumentError, "column name cannot be empty" if name.to_s.empty?

          @name = name
        end
      end
    end
  end
end
