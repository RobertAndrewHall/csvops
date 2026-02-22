# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/builders/column_session_builder"

class ColumnSessionBuilderTest < Minitest::Test
  def test_builds_column_session
    builder = Csvtool::Interface::CLI::Workflows::Builders::ColumnSessionBuilder.new

    session = builder.call(file_path: "/tmp/data.csv", col_sep: ",", column_name: "name", skip_blanks: true)

    assert_equal "/tmp/data.csv", session.source.path
    assert_equal ",", session.source.separator.value
    assert_equal "name", session.column_selection.name
    assert_equal true, session.options.skip_blanks?
  end
end
