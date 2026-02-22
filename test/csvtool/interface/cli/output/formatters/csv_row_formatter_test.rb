# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/output/formatters/csv_row_formatter"

class CsvRowFormatterTest < Minitest::Test
  def test_formats_row_with_separator
    formatter = Csvtool::Interface::CLI::Output::Formatters::CsvRowFormatter.new

    row = formatter.call(fields: ["Alice", "London"], col_sep: ",")

    assert_equal "Alice,London", row
  end

  def test_quotes_values_when_needed
    formatter = Csvtool::Interface::CLI::Output::Formatters::CsvRowFormatter.new

    row = formatter.call(fields: ["Alice, Jr", "London"], col_sep: ",")

    assert_equal '"Alice, Jr",London', row
  end
end
