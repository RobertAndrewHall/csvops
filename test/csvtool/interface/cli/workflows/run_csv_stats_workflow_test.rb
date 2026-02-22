# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/workflows/run_csv_stats_workflow"

class RunCsvStatsWorkflowTest < Minitest::Test
  def test_workflow_collects_source_path
    out = StringIO.new
    input = ["/tmp/data.csv"].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCsvStatsWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "CSV file path: "
    assert_includes out.string, "Stats workflow ready."
  end
end
