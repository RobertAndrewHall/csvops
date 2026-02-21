# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/column_session/output_destination"

class OutputDestinationTest < Minitest::Test
  def test_console_factory
    destination = Csvtool::Domain::ColumnSession::OutputDestination.console
    assert_equal true, destination.console?
    assert_equal false, destination.file?
  end

  def test_file_factory
    destination = Csvtool::Domain::ColumnSession::OutputDestination.file(path: "/tmp/out.csv")
    assert_equal true, destination.file?
    assert_equal "/tmp/out.csv", destination.path
  end
end
