# frozen_string_literal: true

require "csvtool/domain/cross_csv_dedupe_session/csv_profile"
require "csvtool/domain/cross_csv_dedupe_session/key_mapping"
require "csvtool/domain/cross_csv_dedupe_session/match_options"
require "csvtool/domain/shared/output_destination"

module Csvtool
  module Domain
    module CrossCsvDedupeSession
      class CrossCsvDedupeSession
        attr_reader :source, :reference, :key_mapping, :match_options, :output_destination

        def self.start(source:, reference:, key_mapping:, match_options:)
          new(source: source, reference: reference, key_mapping: key_mapping, match_options: match_options)
        end

        def initialize(source:, reference:, key_mapping:, match_options:, output_destination: nil)
          raise ArgumentError, "source must be CsvProfile" unless source.is_a?(CsvProfile)
          raise ArgumentError, "reference must be CsvProfile" unless reference.is_a?(CsvProfile)
          raise ArgumentError, "key_mapping must be KeyMapping" unless key_mapping.is_a?(KeyMapping)
          raise ArgumentError, "match_options must be MatchOptions" unless match_options.is_a?(MatchOptions)
          unless output_destination.nil? || output_destination.is_a?(Domain::Shared::OutputDestination)
            raise ArgumentError, "output_destination must be OutputDestination or nil"
          end

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
