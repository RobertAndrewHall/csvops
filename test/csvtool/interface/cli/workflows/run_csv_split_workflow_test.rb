# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/workflows/run_csv_split_workflow"

class RunCsvSplitWorkflowTest < Minitest::Test
  def test_workflow_collects_source_and_chunk_size
    out = StringIO.new
    input = ["/tmp/data.csv", "10"].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCsvSplitWorkflow.new(
      stdin: StringIO.new(input),
      stdout: out
    ).call

    assert_includes out.string, "Source CSV file path: "
    assert_includes out.string, "Rows per chunk: "
    assert_includes out.string, "Split workflow ready."
  end
end
