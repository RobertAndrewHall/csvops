# frozen_string_literal: true

require_relative "test_helper"
require "csvtool/cli"

class TestCli < Minitest::Test
  def test_menu_displays_expected_options
    output = StringIO.new
    error = StringIO.new

    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new("2\n"),
      stdout: output,
      stderr: error
    )

    text = output.string
    assert_equal 0, status
    assert_includes text, "CSV Tool Menu"
    assert_includes text, "1. Extract column"
    assert_includes text, "2. Exit"
  end

  def test_menu_contains_only_story_one_options
    output = StringIO.new

    Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new("2\n"),
      stdout: output,
      stderr: StringIO.new
    )

    menu_lines = output.string.lines.select { |line| line.match?(/^\d+\.\s/) }.map(&:strip)
    assert_equal ["1. Extract column", "2. Exit"], menu_lines
  end

  def test_invalid_choice_then_exit_is_safe
    output = StringIO.new
    error = StringIO.new

    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new("x\n2\n"),
      stdout: output,
      stderr: error
    )

    assert_equal 0, status
    assert_includes output.string, "Please choose 1 or 2."
  end
end
