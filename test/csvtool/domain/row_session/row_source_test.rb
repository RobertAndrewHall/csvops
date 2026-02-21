# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_session/row_source"

class RowSourceTest < Minitest::Test
  def test_holds_path_and_separator
    source = Csvtool::Domain::RowSession::RowSource.new(path: "/tmp/a.csv", separator: "\t")
    assert_equal "/tmp/a.csv", source.path
    assert_equal "\t", source.separator
  end
end
