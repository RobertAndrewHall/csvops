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

  def test_routes_extract_then_exit
    action = FakeAction.new
    stdout = StringIO.new
    menu = Csvtool::Interface::CLI::MenuLoop.new(
      stdin: StringIO.new("1\n2\n"),
      stdout: stdout,
      menu_options: ["Extract column", "Exit"],
      extract_action: action
    )

    status = menu.run

    assert_equal 0, status
    assert_equal 1, action.runs
    assert_includes stdout.string, "CSV Tool Menu"
  end

  def test_invalid_choice_shows_prompt
    action = FakeAction.new
    stdout = StringIO.new
    menu = Csvtool::Interface::CLI::MenuLoop.new(
      stdin: StringIO.new("x\n2\n"),
      stdout: stdout,
      menu_options: ["Extract column", "Exit"],
      extract_action: action
    )

    menu.run

    assert_includes stdout.string, "Please choose 1 or 2."
    assert_equal 0, action.runs
  end
end
