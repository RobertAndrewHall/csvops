# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/extraction_session/preview"
require "csvtool/domain/extraction_session/extraction_value"

class PreviewTest < Minitest::Test
  def test_exposes_size_and_string_values
    values = [
      Csvtool::Domain::ExtractionSession::ExtractionValue.new("Alice"),
      Csvtool::Domain::ExtractionSession::ExtractionValue.new("Bob")
    ]
    preview = Csvtool::Domain::ExtractionSession::Preview.new(values: values)

    assert_equal 2, preview.size
    assert_equal %w[Alice Bob], preview.to_strings
  end
end
