# frozen_string_literal: true

require_relative "test_helper"
require "csvtool/extract_column_workflow"

class ExtractColumnWorkflowTest < Minitest::Test
  def test_missing_file_path_reports_error
    out = StringIO.new
    workflow = Csvtool::ExtractColumnWorkflow.new(
      stdin: StringIO.new("/tmp/not-present.csv\n"),
      stdout: out
    )

    workflow.run

    assert_includes out.string, "File not found: /tmp/not-present.csv"
  end

  def test_workflow_can_run_console_happy_path
    out = StringIO.new
    fixture = File.expand_path("fixtures/sample_people.csv", __dir__)
    input = ["#{fixture}", "1", "", "1", "", "y", ""].join("\n") + "\n"

    workflow = Csvtool::ExtractColumnWorkflow.new(stdin: StringIO.new(input), stdout: out)
    workflow.run

    assert_includes out.string, "Alice"
    assert_includes out.string, "Bob"
    assert_includes out.string, "Cara"
  end
end
