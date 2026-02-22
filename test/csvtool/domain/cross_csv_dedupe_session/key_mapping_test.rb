# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/cross_csv_dedupe_session/key_mapping"
require "csvtool/domain/cross_csv_dedupe_session/column_selector"

class CrossCsvDedupeKeyMappingTest < Minitest::Test
  def test_holds_source_and_reference_selectors
    source_selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: true, input: "source_id")
    reference_selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: true, input: "ref_id")

    mapping = Csvtool::Domain::CrossCsvDedupeSession::KeyMapping.new(
      source_selector: source_selector,
      reference_selector: reference_selector
    )

    assert_equal source_selector, mapping.source_selector
    assert_equal reference_selector, mapping.reference_selector
  end
end
