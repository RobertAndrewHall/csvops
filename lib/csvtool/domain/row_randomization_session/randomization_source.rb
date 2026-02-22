# frozen_string_literal: true

module Csvtool
  module Domain
    module RowRandomizationSession
      class RandomizationSource
        attr_reader :path, :separator

        def initialize(path:, separator:, headers_present:)
          raise ArgumentError, "path cannot be empty" if path.to_s.empty?
          raise ArgumentError, "separator cannot be empty" if separator.to_s.empty?

          @path = path
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
