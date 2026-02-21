# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/column_session/extraction_value"

class ExtractionValueTest < Minitest::Test
  def test_stringifies_value
    value = Csvtool::Domain::ColumnSession::ExtractionValue.new(123)
    assert_equal "123", value.value
  end
end
