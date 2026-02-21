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
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new("4\n"), stdout: StringIO.new, stderr: StringIO.new)
    assert_equal 0, status
  end

  def test_column_command_requires_file_and_column_args
    status = Csvtool::CLI.start(["column"], stdin: StringIO.new, stdout: StringIO.new, stderr: StringIO.new)
    assert_equal 1, status
  end

  def test_menu_routes_to_row_range_shell
    stdout = StringIO.new
    fixture = File.expand_path("../fixtures/sample_people.csv", __dir__)
    input = ["2", fixture, "", "2", "3", "", "4"].join("\n") + "\n"
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: stdout, stderr: StringIO.new)
    assert_equal 0, status
    assert_includes stdout.string, "name,city"
    assert_includes stdout.string, "Bob,Paris"
    assert_includes stdout.string, "Cara,Berlin"
  end

  def test_menu_routes_to_randomize_rows_shell
    stdout = StringIO.new
    fixture = File.expand_path("../fixtures/sample_people.csv", __dir__)
    input = ["3", fixture, "4"].join("\n") + "\n"
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: stdout, stderr: StringIO.new)
    assert_equal 0, status
    assert_includes stdout.string, "Randomize rows workflow selected for: #{fixture}"
    assert_includes stdout.string, "Row randomization implementation is next."
  end
end
