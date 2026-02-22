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
    menu, actions, = build_menu("1\n8\n")
    status = menu.run

    assert_equal 0, status
    assert_equal 1, actions[:column].runs
    assert_equal 0, actions[:rows].runs
    assert_equal 0, actions[:randomize].runs
    assert_equal 0, actions[:dedupe].runs
    assert_equal 0, actions[:parity].runs
    assert_equal 0, actions[:split].runs
    assert_equal 0, actions[:stats].runs
  end

  def test_routes_extract_rows_then_exit
    menu, actions, = build_menu("2\n8\n")
    status = menu.run

    assert_equal 0, status
    assert_equal 0, actions[:column].runs
    assert_equal 1, actions[:rows].runs
    assert_equal 0, actions[:randomize].runs
    assert_equal 0, actions[:dedupe].runs
    assert_equal 0, actions[:parity].runs
    assert_equal 0, actions[:split].runs
    assert_equal 0, actions[:stats].runs
  end

  def test_routes_randomize_rows_then_exit
    menu, actions, = build_menu("3\n8\n")
    status = menu.run

    assert_equal 0, status
    assert_equal 0, actions[:column].runs
    assert_equal 0, actions[:rows].runs
    assert_equal 1, actions[:randomize].runs
    assert_equal 0, actions[:dedupe].runs
    assert_equal 0, actions[:parity].runs
    assert_equal 0, actions[:split].runs
    assert_equal 0, actions[:stats].runs
  end

  def test_routes_dedupe_then_exit
    menu, actions, = build_menu("4\n8\n")
    status = menu.run

    assert_equal 0, status
    assert_equal 0, actions[:column].runs
    assert_equal 0, actions[:rows].runs
    assert_equal 0, actions[:randomize].runs
    assert_equal 1, actions[:dedupe].runs
    assert_equal 0, actions[:parity].runs
    assert_equal 0, actions[:split].runs
    assert_equal 0, actions[:stats].runs
  end

  def test_routes_parity_then_exit
    menu, actions, = build_menu("5\n8\n")
    status = menu.run

    assert_equal 0, status
    assert_equal 0, actions[:column].runs
    assert_equal 0, actions[:rows].runs
    assert_equal 0, actions[:randomize].runs
    assert_equal 0, actions[:dedupe].runs
    assert_equal 1, actions[:parity].runs
    assert_equal 0, actions[:split].runs
    assert_equal 0, actions[:stats].runs
  end

  def test_routes_split_then_exit
    menu, actions, stdout = build_menu("6\n8\n")
    status = menu.run

    assert_equal 0, status
    assert_equal 0, actions[:column].runs
    assert_equal 0, actions[:rows].runs
    assert_equal 0, actions[:randomize].runs
    assert_equal 0, actions[:dedupe].runs
    assert_equal 0, actions[:parity].runs
    assert_equal 1, actions[:split].runs
    assert_equal 0, actions[:stats].runs
    assert_includes stdout.string, "CSV Tool Menu"
  end

  def test_routes_stats_then_exit
    menu, actions, = build_menu("7\n8\n")
    status = menu.run

    assert_equal 0, status
    assert_equal 0, actions[:column].runs
    assert_equal 0, actions[:rows].runs
    assert_equal 0, actions[:randomize].runs
    assert_equal 0, actions[:dedupe].runs
    assert_equal 0, actions[:parity].runs
    assert_equal 0, actions[:split].runs
    assert_equal 1, actions[:stats].runs
  end

  def test_invalid_choice_shows_prompt
    menu, actions, stdout = build_menu("x\n8\n")
    menu.run

    assert_includes stdout.string, "Please choose 1, 2, 3, 4, 5, 6, 7, or 8."
    assert_equal 0, actions[:column].runs
    assert_equal 0, actions[:rows].runs
    assert_equal 0, actions[:randomize].runs
    assert_equal 0, actions[:dedupe].runs
    assert_equal 0, actions[:parity].runs
    assert_equal 0, actions[:split].runs
    assert_equal 0, actions[:stats].runs
  end

  private

  def build_menu(input)
    actions = {
      column: FakeAction.new,
      rows: FakeAction.new,
      randomize: FakeAction.new,
      dedupe: FakeAction.new,
      parity: FakeAction.new,
      split: FakeAction.new,
      stats: FakeAction.new
    }
    stdout = StringIO.new

    menu = Csvtool::Interface::CLI::MenuLoop.new(
      stdin: StringIO.new(input),
      stdout: stdout,
      menu_options: ["Extract column", "Extract rows (range)", "Randomize rows", "Dedupe using another CSV", "Validate parity", "Split CSV into chunks", "CSV stats summary", "Exit"],
      extract_column_action: actions[:column],
      extract_rows_action: actions[:rows],
      randomize_rows_action: actions[:randomize],
      dedupe_action: actions[:dedupe],
      parity_action: actions[:parity],
      split_action: actions[:split],
      stats_action: actions[:stats]
    )

    [menu, actions, stdout]
  end
end
