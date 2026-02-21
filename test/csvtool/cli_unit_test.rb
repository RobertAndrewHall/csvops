# frozen_string_literal: true

require_relative "../test_helper"
require "csvtool/cli"

class CliUnitTest < Minitest::Test
  def test_unknown_command_prints_usage_and_returns_one
    stdout = StringIO.new
    stderr = StringIO.new

    status = Csvtool::CLI.start(["unknown"], stdin: StringIO.new, stdout: stdout, stderr: stderr)

    assert_equal 1, status
    assert_includes stderr.string, "csvtool menu"
    assert_includes stderr.string, "csvtool column <file> <column>"
  end

  def test_menu_command_can_exit_zero
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new("3\n"), stdout: StringIO.new, stderr: StringIO.new)
    assert_equal 0, status
  end

  def test_column_command_requires_file_and_column_args
    status = Csvtool::CLI.start(["column"], stdin: StringIO.new, stdout: StringIO.new, stderr: StringIO.new)
    assert_equal 1, status
  end

  def test_menu_routes_to_row_range_shell
    stdout = StringIO.new
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new("2\n3\n"), stdout: stdout, stderr: StringIO.new)
    assert_equal 0, status
    assert_includes stdout.string, "Row-range extraction workflow"
  end
end
