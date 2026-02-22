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
    assert_includes out.string, "Chunk size: 10"
    assert_includes out.string, "Data rows: 25"
    assert_includes out.string, "Chunks written: 3"
    assert_includes out.string, "Manifest: /tmp/manifest.csv"
    assert_includes out.string, "/tmp/people_part_001.csv"
  end
end
