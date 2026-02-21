# frozen_string_literal: true

require_relative "../test_helper"
require "csvtool/menu_loop"

class MenuLoopTest < Minitest::Test
  class FakeWorkflow
    attr_reader :runs

    def initialize
      @runs = 0
    end

    def run
      @runs += 1
    end
  end

  def test_routes_extract_then_exit
    workflow = FakeWorkflow.new
    stdout = StringIO.new
    menu = Csvtool::MenuLoop.new(
      stdin: StringIO.new("1\n2\n"),
      stdout: stdout,
      menu_options: ["Extract column", "Exit"],
      extract_workflow: workflow
    )

    status = menu.run

    assert_equal 0, status
    assert_equal 1, workflow.runs
    assert_includes stdout.string, "CSV Tool Menu"
  end

  def test_invalid_choice_shows_prompt
    workflow = FakeWorkflow.new
    stdout = StringIO.new
    menu = Csvtool::MenuLoop.new(
      stdin: StringIO.new("x\n2\n"),
      stdout: stdout,
      menu_options: ["Extract column", "Exit"],
      extract_workflow: workflow
    )

    menu.run

    assert_includes stdout.string, "Please choose 1 or 2."
    assert_equal 0, workflow.runs
  end
end
