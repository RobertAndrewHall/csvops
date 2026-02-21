# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/column_session/preview"
require "csvtool/domain/column_session/extraction_value"

class PreviewTest < Minitest::Test
  def test_exposes_size_and_string_values
    values = [
      Csvtool::Domain::ColumnSession::ExtractionValue.new("Alice"),
      Csvtool::Domain::ColumnSession::ExtractionValue.new("Bob")
    ]
    preview = Csvtool::Domain::ColumnSession::Preview.new(values: values)

    assert_equal 2, preview.size
    assert_equal %w[Alice Bob], preview.to_strings
  end
end
