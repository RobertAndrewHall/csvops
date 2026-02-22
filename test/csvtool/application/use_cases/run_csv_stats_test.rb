# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_csv_stats"
require "csvtool/domain/csv_stats_session/stats_source"
require "csvtool/domain/csv_stats_session/stats_options"
require "csvtool/domain/csv_stats_session/stats_session"
require "csvtool/domain/shared/output_destination"
require "tmpdir"

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

  def test_writes_stats_to_file_when_file_output_selected
    Dir.mktmpdir do |dir|
      source = Csvtool::Domain::CsvStatsSession::StatsSource.new(
        path: fixture_path("sample_people.csv"),
        separator: ",",
        headers_present: true
      )
      session = Csvtool::Domain::CsvStatsSession::StatsSession.start(
        source: source,
        options: Csvtool::Domain::CsvStatsSession::StatsOptions.new
      ).with_output_destination(Csvtool::Domain::Shared::OutputDestination.file(path: File.join(dir, "stats.csv")))

      result = Csvtool::Application::UseCases::RunCsvStats.new.call(session: session)

      assert result.ok?
      assert_equal session.output_destination.path, result.data[:output_path]
      csv_text = File.read(session.output_destination.path)
      assert_includes csv_text, "metric,value"
      assert_includes csv_text, "row_count,3"
      assert_includes csv_text, "column_count,2"
    end
  end

  def test_returns_cannot_write_output_file_when_writer_fails
    source = Csvtool::Domain::CsvStatsSession::StatsSource.new(
      path: fixture_path("sample_people.csv"),
      separator: ",",
      headers_present: true
    )
    session = Csvtool::Domain::CsvStatsSession::StatsSession.start(
      source: source,
      options: Csvtool::Domain::CsvStatsSession::StatsOptions.new
    ).with_output_destination(Csvtool::Domain::Shared::OutputDestination.file(path: "/tmp/out.csv"))
    writer = Object.new
    def writer.call(path:, data:)
      raise Errno::EACCES, path
    end

    result = Csvtool::Application::UseCases::RunCsvStats.new(csv_stats_file_writer: writer).call(session: session)

    refute result.ok?
    assert_equal :cannot_write_output_file, result.error
    assert_equal "/tmp/out.csv", result.data[:path]
    assert_equal Errno::EACCES, result.data[:error_class]
  end
end
