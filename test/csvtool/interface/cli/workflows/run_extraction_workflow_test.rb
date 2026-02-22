# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/workflows/run_extraction_workflow"
require "tmpdir"

class RunExtractionWorkflowTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../../fixtures/#{name}", __dir__)
  end

  def test_missing_file_path_reports_error
    out = StringIO.new
    workflow = Csvtool::Interface::CLI::Workflows::RunExtractionWorkflow.new(
      stdin: StringIO.new("/tmp/not-present.csv\n\n"),
      stdout: out
    )

    workflow.call

    assert_includes out.string, "File not found: /tmp/not-present.csv"
  end

  def test_workflow_can_run_console_happy_path
    out = StringIO.new
    fixture = fixture_path("sample_people.csv")
    input = ["#{fixture}", "1", "", "1", "", "y", ""].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunExtractionWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "Alice"
    assert_includes out.string, "Bob"
    assert_includes out.string, "Cara"
  end

  def test_workflow_can_write_output_file
    out = StringIO.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "names.csv")
      fixture = fixture_path("sample_people.csv")
      input = ["#{fixture}", "1", "", "1", "", "y", "2", output_path].join("\n") + "\n"

      Csvtool::Interface::CLI::Workflows::RunExtractionWorkflow.new(
        stdin: StringIO.new(input),
        stdout: out
      ).call

      assert_includes out.string, "Wrote output to #{output_path}"
      assert_equal "name\nAlice\nBob\nCara\n", File.read(output_path)
    end
  end
end
