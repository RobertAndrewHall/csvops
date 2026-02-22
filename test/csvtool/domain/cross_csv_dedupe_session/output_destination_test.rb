# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/cross_csv_dedupe_session/output_destination"

class CrossCsvDedupeOutputDestinationTest < Minitest::Test
  def test_builds_console_destination
    destination = Csvtool::Domain::CrossCsvDedupeSession::OutputDestination.console

    assert_equal false, destination.file?
  end

  def test_builds_file_destination
    destination = Csvtool::Domain::CrossCsvDedupeSession::OutputDestination.file(path: "/tmp/out.csv")

    assert_equal true, destination.file?
    assert_equal "/tmp/out.csv", destination.path
  end
end
