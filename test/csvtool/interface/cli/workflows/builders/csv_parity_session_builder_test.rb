# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/builders/csv_parity_session_builder"

class CsvParitySessionBuilderTest < Minitest::Test
  def test_builds_parity_session
    session = Csvtool::Interface::CLI::Workflows::Builders::CsvParitySessionBuilder.new.call(
      left_path: "/tmp/left.csv",
      right_path: "/tmp/right.csv",
      col_sep: "\t",
      headers_present: false
    )

    assert_equal "/tmp/left.csv", session.source_pair.left_path
    assert_equal "/tmp/right.csv", session.source_pair.right_path
    assert_equal "\t", session.options.separator
    assert_equal false, session.options.headers_present?
  end
end
