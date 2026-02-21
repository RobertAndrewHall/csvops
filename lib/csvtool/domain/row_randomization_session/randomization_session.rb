# frozen_string_literal: true

module Csvtool
  module Domain
    module RowRandomizationSession
      class RandomizationSession
        attr_reader :source, :options, :output_destination

        def self.start(source:, options:)
          new(source: source, options: options)
        end

        def initialize(source:, options:, output_destination: nil)
          @source = source
          @options = options
          @output_destination = output_destination
        end

        def with_output_destination(destination)
          self.class.new(source: @source, options: @options, output_destination: destination)
        end
      end
    end
  end
end
