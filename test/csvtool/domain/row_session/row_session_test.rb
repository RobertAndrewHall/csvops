# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_session/row_session"
require "csvtool/domain/row_session/row_source"
require "csvtool/domain/row_session/row_range"
require "csvtool/domain/shared/output_destination"

class RowSessionTest < Minitest::Test
  def test_starts_and_sets_output_destination
    source = Csvtool::Domain::RowSession::RowSource.new(path: "/tmp/a.csv", separator: ",")
    row_range = Csvtool::Domain::RowSession::RowRange.new(start_row: 1, end_row: 2)

    session = Csvtool::Domain::RowSession::RowSession.start(source: source, row_range: row_range)
    destination = Csvtool::Domain::Shared::OutputDestination.console
    updated = session.with_output_destination(destination)

    assert_equal source, updated.source
    assert_equal row_range, updated.row_range
    assert_equal destination, updated.output_destination
  end
end
