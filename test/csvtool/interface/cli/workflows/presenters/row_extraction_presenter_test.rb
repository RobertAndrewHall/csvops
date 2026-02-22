# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/presenters/row_extraction_presenter"

class RowExtractionPresenterTest < Minitest::Test
  def test_prints_header_once_then_rows
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::RowExtractionPresenter.new(
      stdout: out,
      headers: ["name", "city"],
      col_sep: ","
    )

    presenter.print_row(["Alice", "London"])
    presenter.print_row(["Bob", "Paris"])

    assert_equal "name,city\nAlice,London\nBob,Paris\n", out.string
  end

  def test_prints_file_written_message
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::RowExtractionPresenter.new(
      stdout: out,
      headers: ["name"],
      col_sep: ","
    )

    presenter.print_file_written("/tmp/out.csv")

    assert_includes out.string, "Wrote output to /tmp/out.csv"
  end
end
