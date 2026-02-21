# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/extraction_session/column_selection"

class ColumnSelectionTest < Minitest::Test
  def test_stores_name
    selection = Csvtool::Domain::ExtractionSession::ColumnSelection.new(name: "city")
    assert_equal "city", selection.name
  end
end
