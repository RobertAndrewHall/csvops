# frozen_string_literal: true

module Csvtool
  module Domain
    module RowSession
      class InvalidStartRowError < StandardError; end
      class InvalidEndRowError < StandardError; end
      class InvalidRowRangeOrderError < StandardError; end

      class RowRange
        attr_reader :start_row, :end_row

        def self.from_inputs(start_row_input:, end_row_input:)
          unless /\A[1-9]\d*\z/.match?(start_row_input.to_s)
            raise InvalidStartRowError, "invalid start row"
          end
          unless /\A[1-9]\d*\z/.match?(end_row_input.to_s)
            raise InvalidEndRowError, "invalid end row"
          end

          start_row = start_row_input.to_i
          end_row = end_row_input.to_i
          raise InvalidRowRangeOrderError, "end row before start row" if end_row < start_row

          new(start_row: start_row, end_row: end_row)
        end

        def initialize(start_row:, end_row:)
          raise InvalidStartRowError, "invalid start row" unless start_row.to_i >= 1
          raise InvalidEndRowError, "invalid end row" unless end_row.to_i >= 1
          raise InvalidRowRangeOrderError, "end row before start row" if end_row < start_row

          @start_row = start_row
          @end_row = end_row
        end
      end
    end
  end
end
