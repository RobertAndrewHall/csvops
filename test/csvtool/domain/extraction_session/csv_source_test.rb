# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/extraction_session/csv_source"
require "csvtool/domain/extraction_session/separator"

class CsvSourceTest < Minitest::Test
  def test_stores_path_and_separator
    separator = Csvtool::Domain::ExtractionSession::Separator.new(",")
    source = Csvtool::Domain::ExtractionSession::CsvSource.new(path: "/tmp/a.csv", separator: separator)
    assert_equal "/tmp/a.csv", source.path
    assert_equal separator, source.separator
  end
end
