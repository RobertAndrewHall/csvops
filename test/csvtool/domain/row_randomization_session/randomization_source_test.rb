# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_randomization_session/randomization_source"

class RandomizationSourceTest < Minitest::Test
  def test_holds_path_separator_and_headers_mode
    source = Csvtool::Domain::RowRandomizationSession::RandomizationSource.new(
      path: "/tmp/a.csv",
      separator: ",",
      headers_present: true
    )

    assert_equal "/tmp/a.csv", source.path
    assert_equal ",", source.separator
    assert_equal true, source.headers_present?
  end

  def test_rejects_empty_separator
    assert_raises(ArgumentError) do
      Csvtool::Domain::RowRandomizationSession::RandomizationSource.new(
        path: "/tmp/a.csv",
        separator: "",
        headers_present: true
      )
    end
  end
end
