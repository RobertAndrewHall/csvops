# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_csv_stats"
require "csvtool/domain/csv_stats_session/stats_source"
require "csvtool/domain/csv_stats_session/stats_options"
require "csvtool/domain/csv_stats_session/stats_session"

class RunCsvStatsTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_returns_core_stats_summary
    source = Csvtool::Domain::CsvStatsSession::StatsSource.new(
      path: fixture_path("sample_people.csv"),
      separator: ",",
      headers_present: true
    )
    session = Csvtool::Domain::CsvStatsSession::StatsSession.start(
      source: source,
      options: Csvtool::Domain::CsvStatsSession::StatsOptions.new
    )

    result = Csvtool::Application::UseCases::RunCsvStats.new.call(session: session)

    assert result.ok?
    assert_equal 3, result.data[:row_count]
    assert_equal 2, result.data[:column_count]
    assert_equal ["name", "city"], result.data[:headers]
  end
end
