# frozen_string_literal: true

module Csvtool
  module Domain
    module CsvStatsSession
      class StatsSession
        attr_reader :source, :options, :output_destination

        def self.start(source:, options:)
          new(source: source, options: options)
        end

        def initialize(source:, options:, output_destination: nil)
          @source = source
          @options = options
          @output_destination = output_destination
        end

        def with_output_destination(output_destination)
          self.class.new(source: source, options: options, output_destination: output_destination)
        end
      end
    end
  end
end
