# frozen_string_literal: true

module Csvtool
  module Domain
    module CsvParitySession
      class ParityOptions
        attr_reader :separator

        def initialize(separator:, headers_present:)
          raise ArgumentError, "separator cannot be empty" if separator.to_s.empty?

          @separator = separator
          @headers_present = headers_present
        end

        def headers_present?
          @headers_present
        end
      end
    end
  end
end
