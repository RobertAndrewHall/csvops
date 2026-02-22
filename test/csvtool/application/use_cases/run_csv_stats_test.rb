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
    assert_equal [
      { name: "name", blank_count: 0, non_blank_count: 3 },
      { name: "city", blank_count: 0, non_blank_count: 3 }
    ], result.data[:column_stats]
  end

  def test_supports_tsv_separator
    source = Csvtool::Domain::CsvStatsSession::StatsSource.new(
      path: fixture_path("sample_people.tsv"),
      separator: "\t",
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

  def test_supports_headerless_mode
    source = Csvtool::Domain::CsvStatsSession::StatsSource.new(
      path: fixture_path("sample_people_no_headers.csv"),
      separator: ",",
      headers_present: false
    )
    session = Csvtool::Domain::CsvStatsSession::StatsSession.start(
      source: source,
      options: Csvtool::Domain::CsvStatsSession::StatsOptions.new
    )

    result = Csvtool::Application::UseCases::RunCsvStats.new.call(session: session)

    assert result.ok?
    assert_equal 3, result.data[:row_count]
    assert_equal 2, result.data[:column_count]
    assert_nil result.data[:headers]
    assert_equal [
      { name: "column_1", blank_count: 0, non_blank_count: 3 },
      { name: "column_2", blank_count: 0, non_blank_count: 3 }
    ], result.data[:column_stats]
  end

  def test_supports_custom_separator
    source = Csvtool::Domain::CsvStatsSession::StatsSource.new(
      path: fixture_path("sample_people_colon.txt"),
      separator: ":",
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

  def test_computes_blank_and_non_blank_counts
    source = Csvtool::Domain::CsvStatsSession::StatsSource.new(
      path: fixture_path("sample_people_blanks.csv"),
      separator: ",",
      headers_present: true
    )
    session = Csvtool::Domain::CsvStatsSession::StatsSession.start(
      source: source,
      options: Csvtool::Domain::CsvStatsSession::StatsOptions.new
    )

    result = Csvtool::Application::UseCases::RunCsvStats.new.call(session: session)

    assert result.ok?
    assert_equal [
      { name: "name", blank_count: 2, non_blank_count: 3 },
      { name: "city", blank_count: 1, non_blank_count: 4 }
    ], result.data[:column_stats]
  end
end
