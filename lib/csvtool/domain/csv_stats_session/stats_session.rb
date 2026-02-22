# frozen_string_literal: true

module Csvtool
  module Domain
    module CsvStatsSession
      class StatsSession
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
