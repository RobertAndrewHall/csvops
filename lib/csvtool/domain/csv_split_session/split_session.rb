# frozen_string_literal: true

module Csvtool
  module Domain
    module CsvSplitSession
      class SplitSession
        attr_reader :source, :options

        def self.start(source:, options:)
          new(source: source, options: options)
        end

        def initialize(source:, options:)
          @source = source
          @options = options
        end
      end
    end
  end
end
