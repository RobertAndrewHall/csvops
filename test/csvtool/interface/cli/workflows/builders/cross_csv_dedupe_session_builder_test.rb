# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/builders/cross_csv_dedupe_session_builder"
require "csvtool/domain/cross_csv_dedupe_session/csv_profile"
require "csvtool/domain/cross_csv_dedupe_session/column_selector"
require "csvtool/domain/shared/output_destination"

class CrossCsvDedupeSessionBuilderTest < Minitest::Test
  def test_builds_cross_csv_dedupe_session
    builder = Csvtool::Interface::CLI::Workflows::Builders::CrossCsvDedupeSessionBuilder.new
    source = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(path: "/tmp/source.csv", separator: ",", headers_present: true)
    reference = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(path: "/tmp/reference.csv", separator: ",", headers_present: true)
    source_selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: true, input: "id")
    reference_selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: true, input: "rid")
    destination = Csvtool::Domain::Shared::OutputDestination.console

    session = builder.call(
      source: source,
      reference: reference,
      source_selector: source_selector,
      reference_selector: reference_selector,
      trim_whitespace: true,
      case_insensitive: false,
      destination: destination
    )

    assert_equal "/tmp/source.csv", session.source.path
    assert_equal "/tmp/reference.csv", session.reference.path
    assert_equal "id", session.key_mapping.source_selector.value
    assert_equal "rid", session.key_mapping.reference_selector.value
    assert_equal true, session.match_options.trim_whitespace?
    assert_equal false, session.match_options.case_insensitive?
    assert_equal true, session.output_destination.console?
  end
end
