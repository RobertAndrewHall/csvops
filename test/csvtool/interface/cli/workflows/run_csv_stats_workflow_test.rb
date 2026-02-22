# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/workflows/run_csv_stats_workflow"

class RunCsvStatsWorkflowTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../../fixtures/#{name}", __dir__)
  end

  def test_workflow_prints_core_stats_summary
    out = StringIO.new
    input = [fixture_path("sample_people.csv"), "", ""].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCsvStatsWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "CSV Stats Summary"
    assert_includes out.string, "Rows: 3"
    assert_includes out.string, "Columns: 2"
    assert_includes out.string, "Headers: name, city"
    assert_includes out.string, "Column completeness:"
    assert_includes out.string, "name: non_blank=3 blank=0"
    assert_includes out.string, "city: non_blank=3 blank=0"
  end

  def test_workflow_supports_tsv_separator
    out = StringIO.new
    input = [fixture_path("sample_people.tsv"), "2", ""].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCsvStatsWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "Rows: 3"
    assert_includes out.string, "Columns: 2"
    assert_includes out.string, "Headers: name, city"
  end

  def test_workflow_supports_headerless_mode
    out = StringIO.new
    input = [fixture_path("sample_people_no_headers.csv"), "", "n"].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCsvStatsWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "Rows: 3"
    assert_includes out.string, "Columns: 2"
    refute_includes out.string, "Headers:"
    assert_includes out.string, "column_1: non_blank=3 blank=0"
    assert_includes out.string, "column_2: non_blank=3 blank=0"
  end

  def test_workflow_supports_custom_separator
    out = StringIO.new
    input = [fixture_path("sample_people_colon.txt"), "5", ":", ""].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCsvStatsWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "Rows: 3"
    assert_includes out.string, "Columns: 2"
    assert_includes out.string, "Headers: name, city"
  end

  def test_workflow_prints_column_completeness_for_blank_values
    out = StringIO.new
    input = [fixture_path("sample_people_blanks.csv"), "", ""].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCsvStatsWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "name: non_blank=3 blank=2"
    assert_includes out.string, "city: non_blank=4 blank=1"
  end
end
