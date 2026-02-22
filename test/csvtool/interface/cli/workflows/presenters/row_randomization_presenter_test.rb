# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/presenters/row_randomization_presenter"

class RowRandomizationPresenterTest < Minitest::Test
  def test_prints_console_start_and_rows
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::RowRandomizationPresenter.new(
      stdout: out,
      headers: ["name", "city"],
      col_sep: ","
    )

    presenter.print_console_start
    presenter.print_row(["Alice", "London"])

    assert_equal "\nname,city\nAlice,London\n", out.string
  end

  def test_prints_file_written_message
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::RowRandomizationPresenter.new(
      stdout: out,
      headers: nil,
      col_sep: ","
    )

    presenter.print_file_written("/tmp/out.csv")

    assert_includes out.string, "Wrote output to /tmp/out.csv"
  end
end
