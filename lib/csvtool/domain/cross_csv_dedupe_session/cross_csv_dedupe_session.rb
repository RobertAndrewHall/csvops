# frozen_string_literal: true

module Csvtool
  module Domain
    module CrossCsvDedupeSession
      class CrossCsvDedupeSession
        attr_reader :source, :reference, :key_mapping, :match_options, :output_destination

        def self.start(source:, reference:, key_mapping:, match_options:)
          new(source: source, reference: reference, key_mapping: key_mapping, match_options: match_options)
        end

        def initialize(source:, reference:, key_mapping:, match_options:, output_destination: nil)
          @source = source
          @reference = reference
          @key_mapping = key_mapping
          @match_options = match_options
          @output_destination = output_destination
        end

        def with_output_destination(destination)
          self.class.new(
            source: @source,
            reference: @reference,
            key_mapping: @key_mapping,
            match_options: @match_options,
            output_destination: destination
          )
        end
      end
    end
  end
end
