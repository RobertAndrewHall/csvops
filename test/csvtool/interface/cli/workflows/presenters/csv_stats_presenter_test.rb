# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/presenters/csv_stats_presenter"

class CsvStatsPresenterTest < Minitest::Test
  def test_prints_summary_with_headers_and_column_stats
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::CsvStatsPresenter.new(stdout: out)

    presenter.print_summary(
      row_count: 3,
      column_count: 2,
      headers: ["name", "city"],
      column_stats: [
        { name: "name", non_blank_count: 3, blank_count: 0 },
        { name: "city", non_blank_count: 2, blank_count: 1 }
      ]
    )

    assert_includes out.string, "CSV Stats Summary"
    assert_includes out.string, "Metric"
    assert_includes out.string, "Rows"
    assert_includes out.string, "Columns"
    assert_includes out.string, "Headers"
    assert_includes out.string, "Column completeness:"
    assert_includes out.string, "name"
    assert_includes out.string, "city"
  end

  def test_prints_file_written_message
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::CsvStatsPresenter.new(stdout: out)

    presenter.print_file_written("/tmp/stats.csv")

    assert_includes out.string, "Wrote output to /tmp/stats.csv"
  end
end
