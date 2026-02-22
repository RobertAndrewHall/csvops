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
    assert_includes out.string, "Rows: 3"
    assert_includes out.string, "Columns: 2"
    assert_includes out.string, "Headers: name, city"
    assert_includes out.string, "name: non_blank=3 blank=0"
    assert_includes out.string, "city: non_blank=2 blank=1"
  end

  def test_prints_file_written_message
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::CsvStatsPresenter.new(stdout: out)

    presenter.print_file_written("/tmp/stats.csv")

    assert_includes out.string, "Wrote output to /tmp/stats.csv"
  end
end
