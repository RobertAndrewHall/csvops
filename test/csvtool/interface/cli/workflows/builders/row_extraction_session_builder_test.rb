# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/builders/row_extraction_session_builder"
require "csvtool/domain/row_session/row_range"
require "csvtool/domain/shared/output_destination"

class RowExtractionSessionBuilderTest < Minitest::Test
  def test_builds_row_extraction_session
    builder = Csvtool::Interface::CLI::Workflows::Builders::RowExtractionSessionBuilder.new
    row_range = Csvtool::Domain::RowSession::RowRange.new(start_row: 2, end_row: 4)
    destination = Csvtool::Domain::Shared::OutputDestination.console

    session = builder.call(file_path: "/tmp/data.csv", col_sep: ";", row_range: row_range, destination: destination)

    assert_equal "/tmp/data.csv", session.source.path
    assert_equal ";", session.source.separator
    assert_equal 2, session.row_range.start_row
    assert_equal true, session.output_destination.console?
  end
end
