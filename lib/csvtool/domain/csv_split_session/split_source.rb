# frozen_string_literal: true

module Csvtool
  module Domain
    module CsvSplitSession
      class SplitSource
        attr_reader :path, :separator, :headers_present

        def initialize(path:, separator:, headers_present:)
          @path = path
          @separator = separator
          @headers_present = headers_present
        end
      end
    end
  end
end
