# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/extraction_session/separator"

class SeparatorTest < Minitest::Test
  def test_stores_value
    separator = Csvtool::Domain::ExtractionSession::Separator.new(",")
    assert_equal ",", separator.value
  end

  def test_empty_value_raises
    assert_raises(ArgumentError) { Csvtool::Domain::ExtractionSession::Separator.new("") }
  end
end
