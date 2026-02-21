# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/column_session/extraction_options"

class ExtractionOptionsTest < Minitest::Test
  def test_exposes_options
    options = Csvtool::Domain::ColumnSession::ExtractionOptions.new(skip_blanks: true, preview_limit: 10)
    assert_equal true, options.skip_blanks?
    assert_equal 10, options.preview_limit
  end

  def test_non_positive_preview_limit_raises
    assert_raises(ArgumentError) do
      Csvtool::Domain::ColumnSession::ExtractionOptions.new(skip_blanks: true, preview_limit: 0)
    end
  end
end
