# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/builders/csv_stats_session_builder"
require "csvtool/domain/shared/output_destination"

class CsvStatsSessionBuilderTest < Minitest::Test
  def test_builds_stats_session
    builder = Csvtool::Interface::CLI::Workflows::Builders::CsvStatsSessionBuilder.new
    destination = Csvtool::Domain::Shared::OutputDestination.console

    session = builder.call(file_path: "/tmp/data.csv", col_sep: ";", headers_present: false, destination: destination)

    assert_equal "/tmp/data.csv", session.source.path
    assert_equal ";", session.source.separator
    assert_equal false, session.source.headers_present
    assert_equal true, session.output_destination.console?
  end
end
