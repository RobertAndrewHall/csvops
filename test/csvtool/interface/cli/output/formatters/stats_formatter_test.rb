# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/output/formatters/stats_formatter"
require "csvtool/interface/cli/output/table_renderer"
require "json"

class StatsFormatterTest < Minitest::Test
  def sample_data
    {
      row_count: 3,
      column_count: 2,
      headers: ["name", "city"],
      column_stats: [
        { name: "name", non_blank_count: 3, blank_count: 0 },
        { name: "city", non_blank_count: 2, blank_count: 1 }
      ]
    }
  end

  def formatter
    Csvtool::Interface::CLI::Output::Formatters::StatsFormatter.new(
      table_renderer: Csvtool::Interface::CLI::Output::TableRenderer.new
    )
  end

  def test_formats_text_summary
    text = formatter.call(data: sample_data, format: "text", max_width: 80)

    assert_includes text, "CSV Stats Summary"
    assert_includes text, "Metric"
    assert_includes text, "Column completeness:"
  end

  def test_formats_json_summary
    json = formatter.call(data: sample_data, format: "json", max_width: 80)

    parsed = JSON.parse(json, symbolize_names: true)
    assert_equal 3, parsed[:row_count]
    assert_equal 2, parsed[:column_count]
  end

  def test_formats_csv_summary
    csv = formatter.call(data: sample_data, format: "csv", max_width: 80)

    lines = csv.lines.map(&:chomp)
    assert_equal "metric,value", lines.first
    assert_includes lines, "row_count,3"
    assert_includes lines, "column.city.blank,1"
  end
end
