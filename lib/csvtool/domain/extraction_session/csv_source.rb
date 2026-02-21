# frozen_string_literal: true

module Csvtool
  module Domain
    module ExtractionSession
      class CsvSource
        attr_reader :path, :separator

        def initialize(path:, separator:)
          raise ArgumentError, "path cannot be empty" if path.to_s.empty?

          @path = path
          @separator = separator
        end
      end
    end
  end
end
