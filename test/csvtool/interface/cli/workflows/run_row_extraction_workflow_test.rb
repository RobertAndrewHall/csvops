# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/workflows/run_row_extraction_workflow"
require "tmpdir"

class RunRowExtractionWorkflowTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../../fixtures/#{name}", __dir__)
  end

  def test_missing_file_path_reports_error
    out = StringIO.new
    workflow = Csvtool::Interface::CLI::Workflows::RunRowExtractionWorkflow.new(
      stdin: StringIO.new("/tmp/not-present.csv\n\n"),
      stdout: out
    )

    workflow.call

    assert_includes out.string, "File not found: /tmp/not-present.csv"
  end

  def test_workflow_can_run_console_happy_path
    out = StringIO.new
    fixture = fixture_path("sample_people.csv")
    input = [fixture, "", "2", "3", ""].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunRowExtractionWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "name,city"
    assert_includes out.string, "Bob,Paris"
    assert_includes out.string, "Cara,Berlin"
    refute_includes out.string, "Alice,London"
  end

  def test_workflow_can_write_output_file
    out = StringIO.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "rows.csv")
      fixture = fixture_path("sample_people.csv")
      input = [fixture, "", "2", "3", "2", output_path].join("\n") + "\n"

      Csvtool::Interface::CLI::Workflows::RunRowExtractionWorkflow.new(
        stdin: StringIO.new(input),
        stdout: out
      ).call

      assert_includes out.string, "Wrote output to #{output_path}"
      assert_equal "name,city\nBob,Paris\nCara,Berlin\n", File.read(output_path)
    end
  end

  def test_rejects_non_numeric_start_row
    out = StringIO.new
    fixture = fixture_path("sample_people.csv")
    input = [fixture, "", "abc", "3", ""].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunRowExtractionWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "Start row must be a positive integer."
  end

  def test_reports_out_of_bounds_range
    out = StringIO.new
    fixture = fixture_path("sample_people.csv")
    input = [fixture, "", "10", "12", ""].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunRowExtractionWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "Row range is out of bounds. File has 3 data rows."
  end
end
