# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_range_session/row_range"

class RowRangeTest < Minitest::Test
  def test_builds_from_valid_inputs
    row_range = Csvtool::Domain::RowRangeSession::RowRange.from_inputs(start_row_input: "2", end_row_input: "4")
    assert_equal 2, row_range.start_row
    assert_equal 4, row_range.end_row
  end

  def test_rejects_invalid_start_row
    assert_raises(Csvtool::Domain::RowRangeSession::InvalidStartRowError) do
      Csvtool::Domain::RowRangeSession::RowRange.from_inputs(start_row_input: "0", end_row_input: "2")
    end
  end

  def test_rejects_invalid_end_row
    assert_raises(Csvtool::Domain::RowRangeSession::InvalidEndRowError) do
      Csvtool::Domain::RowRangeSession::RowRange.from_inputs(start_row_input: "1", end_row_input: "abc")
    end
  end

  def test_rejects_end_before_start
    assert_raises(Csvtool::Domain::RowRangeSession::InvalidRowRangeOrderError) do
      Csvtool::Domain::RowRangeSession::RowRange.from_inputs(start_row_input: "3", end_row_input: "2")
    end
  end
end
