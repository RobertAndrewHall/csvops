# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/presenters/csv_parity_presenter"

class CsvParityPresenterTest < Minitest::Test
  def test_prints_match_summary
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::CsvParityPresenter.new(stdout: out)

    presenter.print_summary(
      match: true,
      left_rows: 3,
      right_rows: 3,
      left_only_count: 0,
      right_only_count: 0
    )

    assert_includes out.string, "MATCH"
    assert_includes out.string, "Summary: left_rows=3 right_rows=3 left_only=0 right_only=0"
  end

  def test_prints_mismatch_examples
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Workflows::Presenters::CsvParityPresenter.new(stdout: out)

    presenter.print_summary(
      match: false,
      left_rows: 3,
      right_rows: 3,
      left_only_count: 1,
      right_only_count: 1,
      left_only_examples: [{ row: "Cara,Berlin", count_delta: 1 }],
      right_only_examples: [{ row: "Dina,Rome", count_delta: 1 }]
    )

    assert_includes out.string, "MISMATCH"
    assert_includes out.string, "Left-only examples:"
    assert_includes out.string, "Cara,Berlin (count +1)"
    assert_includes out.string, "Right-only examples:"
    assert_includes out.string, "Dina,Rome (count +1)"
  end
end
