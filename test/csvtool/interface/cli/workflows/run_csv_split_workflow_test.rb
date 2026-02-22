# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/workflows/run_csv_split_workflow"
require "tmpdir"
require "fileutils"

class RunCsvSplitWorkflowTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../../fixtures/#{name}", __dir__)
  end

  def test_workflow_splits_into_chunk_files
    out = StringIO.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.csv")
      FileUtils.cp(fixture_path("split_people_25.csv"), source_path)
      input = [source_path, "10"].join("\n") + "\n"

      Csvtool::Interface::CLI::Workflows::RunCsvSplitWorkflow.new(
        stdin: StringIO.new(input),
        stdout: out
      ).call

      assert_includes out.string, "Split complete."
      assert_includes out.string, "Chunk size: 10"
      assert_includes out.string, "Chunks written: 3"
      assert File.file?(File.join(dir, "people_part_001.csv"))
      assert File.file?(File.join(dir, "people_part_002.csv"))
      assert File.file?(File.join(dir, "people_part_003.csv"))
    end
  end
end
