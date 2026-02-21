# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_range_session/row_range_session"
require "csvtool/domain/row_range_session/row_source"
require "csvtool/domain/row_range_session/row_range"
require "csvtool/domain/row_range_session/output_destination"

class RowRangeSessionTest < Minitest::Test
  def test_starts_and_sets_output_destination
    source = Csvtool::Domain::RowRangeSession::RowSource.new(path: "/tmp/a.csv", separator: ",")
    row_range = Csvtool::Domain::RowRangeSession::RowRange.new(start_row: 1, end_row: 2)

    session = Csvtool::Domain::RowRangeSession::RowRangeSession.start(source: source, row_range: row_range)
    destination = Csvtool::Domain::RowRangeSession::OutputDestination.console
    updated = session.with_output_destination(destination)

    assert_equal source, updated.source
    assert_equal row_range, updated.row_range
    assert_equal destination, updated.output_destination
  end
end
