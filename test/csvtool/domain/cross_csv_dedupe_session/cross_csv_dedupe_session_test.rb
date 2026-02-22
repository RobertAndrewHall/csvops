# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/cross_csv_dedupe_session/cross_csv_dedupe_session"
require "csvtool/domain/cross_csv_dedupe_session/csv_profile"
require "csvtool/domain/cross_csv_dedupe_session/column_selector"
require "csvtool/domain/cross_csv_dedupe_session/key_mapping"
require "csvtool/domain/cross_csv_dedupe_session/match_options"
require "csvtool/domain/shared/output_destination"

class CrossCsvDedupeSessionTest < Minitest::Test
  def test_start_and_with_output_destination
    source = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: "/tmp/source.csv",
      separator: ",",
      headers_present: true
    )
    reference = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: "/tmp/reference.csv",
      separator: ",",
      headers_present: true
    )
    key_mapping = Csvtool::Domain::CrossCsvDedupeSession::KeyMapping.new(
      source_selector: Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: true, input: "source_id"),
      reference_selector: Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: true, input: "reference_id")
    )
    match_options = Csvtool::Domain::CrossCsvDedupeSession::MatchOptions.new(
      trim_whitespace: true,
      case_insensitive: false
    )

    session = Csvtool::Domain::CrossCsvDedupeSession::CrossCsvDedupeSession.start(
      source: source,
      reference: reference,
      key_mapping: key_mapping,
      match_options: match_options
    )

    destination = Csvtool::Domain::Shared::OutputDestination.console
    updated = session.with_output_destination(destination)

    assert_equal source, updated.source
    assert_equal reference, updated.reference
    assert_equal key_mapping, updated.key_mapping
    assert_equal match_options, updated.match_options
    assert_equal destination, updated.output_destination
  end

  def test_rejects_invalid_source_type
    reference = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: "/tmp/reference.csv",
      separator: ",",
      headers_present: true
    )
    key_mapping = Csvtool::Domain::CrossCsvDedupeSession::KeyMapping.new(
      source_selector: Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: true, input: "source_id"),
      reference_selector: Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: true, input: "reference_id")
    )
    match_options = Csvtool::Domain::CrossCsvDedupeSession::MatchOptions.new(
      trim_whitespace: true,
      case_insensitive: false
    )

    error = assert_raises(ArgumentError) do
      Csvtool::Domain::CrossCsvDedupeSession::CrossCsvDedupeSession.start(
        source: "bad",
        reference: reference,
        key_mapping: key_mapping,
        match_options: match_options
      )
    end

    assert_equal "source must be CsvProfile", error.message
  end
end
