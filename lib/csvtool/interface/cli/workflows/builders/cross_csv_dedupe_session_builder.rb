# frozen_string_literal: true

require "csvtool/domain/cross_csv_dedupe_session/key_mapping"
require "csvtool/domain/cross_csv_dedupe_session/match_options"
require "csvtool/domain/cross_csv_dedupe_session/cross_csv_dedupe_session"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Builders
          class CrossCsvDedupeSessionBuilder
            def call(source:, reference:, source_selector:, reference_selector:, trim_whitespace:, case_insensitive:, destination:)
              key_mapping = Domain::CrossCsvDedupeSession::KeyMapping.new(
                source_selector: source_selector,
                reference_selector: reference_selector
              )
              match_options = Domain::CrossCsvDedupeSession::MatchOptions.new(
                trim_whitespace: trim_whitespace,
                case_insensitive: case_insensitive
              )

              Domain::CrossCsvDedupeSession::CrossCsvDedupeSession.start(
                source: source,
                reference: reference,
                key_mapping: key_mapping,
                match_options: match_options
              ).with_output_destination(destination)
            end
          end
        end
      end
    end
  end
end
