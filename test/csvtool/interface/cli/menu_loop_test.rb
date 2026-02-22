# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/interface/cli/menu_loop"

class MenuLoopTest < Minitest::Test
  class FakeAction
    attr_reader :runs

    def initialize
      @runs = 0
    end

    def call
      @runs += 1
    end
  end

  def test_routes_extract_column_then_exit
    column_action = FakeAction.new
    rows_action = FakeAction.new
    randomize_rows_action = FakeAction.new
    dedupe_action = FakeAction.new
    stdout = StringIO.new
    menu = Csvtool::Interface::CLI::MenuLoop.new(
      stdin: StringIO.new("1\n5\n"),
      stdout: stdout,
      menu_options: ["Extract column", "Extract rows (range)", "Randomize rows", "Dedupe using another CSV", "Exit"],
      extract_column_action: column_action,
      extract_rows_action: rows_action,
      randomize_rows_action: randomize_rows_action,
      dedupe_action: dedupe_action
    )

    status = menu.run

    assert_equal 0, status
    assert_equal 1, column_action.runs
    assert_equal 0, rows_action.runs
    assert_equal 0, randomize_rows_action.runs
    assert_equal 0, dedupe_action.runs
    assert_includes stdout.string, "CSV Tool Menu"
  end

  def test_routes_extract_rows_then_exit
    column_action = FakeAction.new
    rows_action = FakeAction.new
    randomize_rows_action = FakeAction.new
    dedupe_action = FakeAction.new
    stdout = StringIO.new
    menu = Csvtool::Interface::CLI::MenuLoop.new(
      stdin: StringIO.new("2\n5\n"),
      stdout: stdout,
      menu_options: ["Extract column", "Extract rows (range)", "Randomize rows", "Dedupe using another CSV", "Exit"],
      extract_column_action: column_action,
      extract_rows_action: rows_action,
      randomize_rows_action: randomize_rows_action,
      dedupe_action: dedupe_action
    )

    status = menu.run

    assert_equal 0, status
    assert_equal 0, column_action.runs
    assert_equal 1, rows_action.runs
    assert_equal 0, randomize_rows_action.runs
    assert_equal 0, dedupe_action.runs
  end

  def test_routes_randomize_rows_then_exit
    column_action = FakeAction.new
    rows_action = FakeAction.new
    randomize_rows_action = FakeAction.new
    dedupe_action = FakeAction.new
    stdout = StringIO.new
    menu = Csvtool::Interface::CLI::MenuLoop.new(
      stdin: StringIO.new("3\n5\n"),
      stdout: stdout,
      menu_options: ["Extract column", "Extract rows (range)", "Randomize rows", "Dedupe using another CSV", "Exit"],
      extract_column_action: column_action,
      extract_rows_action: rows_action,
      randomize_rows_action: randomize_rows_action,
      dedupe_action: dedupe_action
    )

    status = menu.run

    assert_equal 0, status
    assert_equal 0, column_action.runs
    assert_equal 0, rows_action.runs
    assert_equal 1, randomize_rows_action.runs
    assert_equal 0, dedupe_action.runs
  end

  def test_routes_dedupe_then_exit
    column_action = FakeAction.new
    rows_action = FakeAction.new
    randomize_rows_action = FakeAction.new
    dedupe_action = FakeAction.new
    stdout = StringIO.new
    menu = Csvtool::Interface::CLI::MenuLoop.new(
      stdin: StringIO.new("4\n5\n"),
      stdout: stdout,
      menu_options: ["Extract column", "Extract rows (range)", "Randomize rows", "Dedupe using another CSV", "Exit"],
      extract_column_action: column_action,
      extract_rows_action: rows_action,
      randomize_rows_action: randomize_rows_action,
      dedupe_action: dedupe_action
    )

    status = menu.run

    assert_equal 0, status
    assert_equal 0, column_action.runs
    assert_equal 0, rows_action.runs
    assert_equal 0, randomize_rows_action.runs
    assert_equal 1, dedupe_action.runs
  end

  def test_invalid_choice_shows_prompt
    column_action = FakeAction.new
    rows_action = FakeAction.new
    randomize_rows_action = FakeAction.new
    dedupe_action = FakeAction.new
    stdout = StringIO.new
    menu = Csvtool::Interface::CLI::MenuLoop.new(
      stdin: StringIO.new("x\n5\n"),
      stdout: stdout,
      menu_options: ["Extract column", "Extract rows (range)", "Randomize rows", "Dedupe using another CSV", "Exit"],
      extract_column_action: column_action,
      extract_rows_action: rows_action,
      randomize_rows_action: randomize_rows_action,
      dedupe_action: dedupe_action
    )

    menu.run

    assert_includes stdout.string, "Please choose 1, 2, 3, 4, or 5."
    assert_equal 0, column_action.runs
    assert_equal 0, rows_action.runs
    assert_equal 0, randomize_rows_action.runs
    assert_equal 0, dedupe_action.runs
  end
end
