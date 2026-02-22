# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/presenters/cross_csv_dedupe_presenter"

class CrossCsvDedupePresenterTest < Minitest::Test
  def test_prints_header_row_and_summary
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::CrossCsvDedupePresenter.new(stdout: out, col_sep: ",")

    presenter.print_header(["id", "name"])
    presenter.print_row(["1", "Alice"])
    presenter.print_summary(source_rows: 5, removed_rows: 3, kept_rows_count: 2)

    assert_includes out.string, "\nid,name\n"
    assert_includes out.string, "1,Alice"
    assert_includes out.string, "Summary: source_rows=5 removed_rows=3 kept_rows=2"
  end

  def test_prints_zero_and_all_removed_messages
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::CrossCsvDedupePresenter.new(stdout: out, col_sep: ",")

    presenter.print_summary(source_rows: 5, removed_rows: 0, kept_rows_count: 5)
    presenter.print_summary(source_rows: 5, removed_rows: 5, kept_rows_count: 0)

    assert_includes out.string, "No rows removed; no matching keys found."
    assert_includes out.string, "All source rows were removed by dedupe."
  end
end
