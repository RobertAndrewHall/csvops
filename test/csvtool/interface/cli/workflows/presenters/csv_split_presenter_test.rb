# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/presenters/csv_split_presenter"

class CsvSplitPresenterTest < Minitest::Test
  def test_prints_summary_and_chunk_paths
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::CsvSplitPresenter.new(stdout: out)

    presenter.print_summary(
      chunk_size: 10,
      data_rows: 25,
      chunk_count: 3,
      manifest_path: "/tmp/manifest.csv",
      chunk_paths: ["/tmp/people_part_001.csv", "/tmp/people_part_002.csv", "/tmp/people_part_003.csv"]
    )

    assert_includes out.string, "Split complete."
    assert_includes out.string, "Metric"
    assert_includes out.string, "Chunk size"
    assert_includes out.string, "Data rows"
    assert_includes out.string, "Chunks written"
    assert_includes out.string, "Manifest"
    assert_includes out.string, "/tmp/people_part_001.csv"
  end

  def test_truncates_summary_table_for_narrow_width
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::CsvSplitPresenter.new(stdout: out, max_width: 26)

    presenter.print_summary(
      chunk_size: 10,
      data_rows: 25,
      chunk_count: 3,
      manifest_path: "/tmp/very/long/path/manifest.csv",
      chunk_paths: []
    )

    lines = out.string.lines.map(&:chomp)
    assert lines.all? { |line| line.empty? || line.length <= 26 }
    assert_includes out.string, "..."
  end
end
