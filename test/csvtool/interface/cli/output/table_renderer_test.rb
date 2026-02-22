# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/output/table_renderer"

class TableRendererTest < Minitest::Test
  def test_renders_aligned_table
    renderer = Csvtool::Interface::CLI::Output::TableRenderer.new

    text = renderer.render(
      headers: ["Metric", "Value"],
      rows: [["Rows", "3"], ["Columns", "2"]],
      max_width: 80
    )

    lines = text.lines.map(&:chomp)
    assert_equal "Metric  | Value", lines[0]
    assert_equal "--------+------", lines[1]
    assert_equal "Rows    | 3    ", lines[2]
    assert_equal "Columns | 2    ", lines[3]
  end

  def test_truncates_cells_when_width_is_narrow
    renderer = Csvtool::Interface::CLI::Output::TableRenderer.new

    text = renderer.render(
      headers: ["Column", "Non-blank", "Blank"],
      rows: [["very_long_column_name", "123456", "0"]],
      max_width: 26
    )

    lines = text.lines.map(&:chomp)
    assert lines.all? { |line| line.length <= 26 }
    assert_includes lines[2], "..."
  end
end
