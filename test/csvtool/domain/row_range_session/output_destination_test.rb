# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_range_session/output_destination"

class RowRangeOutputDestinationTest < Minitest::Test
  def test_console_destination
    destination = Csvtool::Domain::RowRangeSession::OutputDestination.console
    refute destination.file?
  end

  def test_file_destination
    destination = Csvtool::Domain::RowRangeSession::OutputDestination.file(path: "/tmp/out.csv")
    assert destination.file?
    assert_equal "/tmp/out.csv", destination.path
  end

  def test_rejects_empty_file_path
    assert_raises(ArgumentError) do
      Csvtool::Domain::RowRangeSession::OutputDestination.file(path: "")
    end
  end
end
