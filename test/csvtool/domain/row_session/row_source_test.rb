# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_session/row_source"

class RowSourceTest < Minitest::Test
  def test_holds_path_and_separator
    source = Csvtool::Domain::RowSession::RowSource.new(path: "/tmp/a.csv", separator: "\t")
    assert_equal "/tmp/a.csv", source.path
    assert_equal "\t", source.separator
  end

  def test_rejects_empty_path
    error = assert_raises(ArgumentError) do
      Csvtool::Domain::RowSession::RowSource.new(path: "", separator: ",")
    end

    assert_equal "path cannot be empty", error.message
  end

  def test_rejects_empty_separator
    error = assert_raises(ArgumentError) do
      Csvtool::Domain::RowSession::RowSource.new(path: "/tmp/a.csv", separator: "")
    end

    assert_equal "separator cannot be empty", error.message
  end
end
