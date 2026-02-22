# frozen_string_literal: true

module Csvtool
  module Domain
    module CsvParitySession
      class SourcePair
        attr_reader :left_path, :right_path

        def initialize(left_path:, right_path:)
          raise ArgumentError, "left_path cannot be empty" if left_path.to_s.empty?
          raise ArgumentError, "right_path cannot be empty" if right_path.to_s.empty?

          @left_path = left_path
          @right_path = right_path
        end
      end
    end
  end
end
