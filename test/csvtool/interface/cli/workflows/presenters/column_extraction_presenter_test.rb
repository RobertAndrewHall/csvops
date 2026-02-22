# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/presenters/column_extraction_presenter"

class ColumnExtractionPresenterTest < Minitest::Test
  def test_prints_value
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::ColumnExtractionPresenter.new(stdout: out)

    presenter.print_value("Alice")

    assert_equal "Alice\n", out.string
  end

  def test_prints_file_written_message
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::ColumnExtractionPresenter.new(stdout: out)

    presenter.print_file_written("/tmp/names.csv")

    assert_includes out.string, "Wrote output to /tmp/names.csv"
  end
end
