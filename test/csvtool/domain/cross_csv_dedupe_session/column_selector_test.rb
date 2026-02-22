# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/cross_csv_dedupe_session/column_selector"

class CrossCsvDedupeColumnSelectorTest < Minitest::Test
  def test_builds_header_selector_from_input
    selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: true, input: "customer_id")

    assert_equal "customer_id", selector.value
    assert_equal true, selector.headers_present?
  end

  def test_builds_index_selector_from_input
    selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: false, input: "2")

    assert_equal 2, selector.value
    assert_equal true, selector.index?
  end

  def test_rejects_invalid_index_input
    error = assert_raises(ArgumentError) do
      Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: false, input: "0")
    end

    assert_equal "column index must be a positive integer", error.message
  end
end
