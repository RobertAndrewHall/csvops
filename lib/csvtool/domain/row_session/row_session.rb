# frozen_string_literal: true

module Csvtool
  module Domain
    module RowSession
      class RowSession
        attr_reader :source, :row_range, :output_destination

        def self.start(source:, row_range:)
          new(source: source, row_range: row_range)
        end

        def initialize(source:, row_range:, output_destination: nil)
          @source = source
          @row_range = row_range
          @output_destination = output_destination
        end

        def with_output_destination(destination)
          self.class.new(source: @source, row_range: @row_range, output_destination: destination)
        end
      end
    end
  end
end
