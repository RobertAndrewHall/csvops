# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/column_session/csv_source"
require "csvtool/domain/column_session/separator"

class CsvSourceTest < Minitest::Test
  def test_stores_path_and_separator
    separator = Csvtool::Domain::ColumnSession::Separator.new(",")
    source = Csvtool::Domain::ColumnSession::CsvSource.new(path: "/tmp/a.csv", separator: separator)
    assert_equal "/tmp/a.csv", source.path
    assert_equal separator, source.separator
  end

  def test_rejects_empty_path
    separator = Csvtool::Domain::ColumnSession::Separator.new(",")

    error = assert_raises(ArgumentError) do
      Csvtool::Domain::ColumnSession::CsvSource.new(path: "", separator: separator)
    end

    assert_equal "path cannot be empty", error.message
  end
end
