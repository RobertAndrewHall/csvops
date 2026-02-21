# frozen_string_literal: true

require_relative "test_helper"
require "csvtool/cli"

class CliUnitTest < Minitest::Test
  def test_unknown_command_prints_usage_and_returns_one
    stdout = StringIO.new
    stderr = StringIO.new

    status = Csvtool::CLI.start(["unknown"], stdin: StringIO.new, stdout: stdout, stderr: stderr)

    assert_equal 1, status
    assert_includes stderr.string, "Usage: tool menu"
  end

  def test_menu_command_can_exit_zero
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new("2\n"), stdout: StringIO.new, stderr: StringIO.new)
    assert_equal 0, status
  end
end
