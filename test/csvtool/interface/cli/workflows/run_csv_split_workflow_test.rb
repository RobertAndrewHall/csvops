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
      input = [source_path, "", "", "10", "", "", ""].join("\n") + "\n"

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

  def test_workflow_supports_tsv_separator
    out = StringIO.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.tsv")
      FileUtils.cp(fixture_path("sample_people.tsv"), source_path)
      input = [source_path, "2", "", "2", "", "", ""].join("\n") + "\n"

      Csvtool::Interface::CLI::Workflows::RunCsvSplitWorkflow.new(
        stdin: StringIO.new(input),
        stdout: out
      ).call

      chunk_path = File.join(dir, "people_part_001.tsv")
      assert File.file?(chunk_path)
      assert_includes File.read(chunk_path), "name\tcity"
    end
  end

  def test_workflow_supports_headerless_mode
    out = StringIO.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.csv")
      FileUtils.cp(fixture_path("sample_people_no_headers.csv"), source_path)
      input = [source_path, "", "n", "2", "", "", ""].join("\n") + "\n"

      Csvtool::Interface::CLI::Workflows::RunCsvSplitWorkflow.new(
        stdin: StringIO.new(input),
        stdout: out
      ).call

      chunk_path = File.join(dir, "people_part_001.csv")
      lines = File.read(chunk_path).lines.map(&:strip)
      assert_equal "Alice,London", lines.first
      assert_equal "Bob,Paris", lines.last
    end
  end

  def test_workflow_supports_custom_separator
    out = StringIO.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.txt")
      FileUtils.cp(fixture_path("sample_people_colon.txt"), source_path)
      input = [source_path, "5", ":", "", "2", "", "", ""].join("\n") + "\n"

      Csvtool::Interface::CLI::Workflows::RunCsvSplitWorkflow.new(
        stdin: StringIO.new(input),
        stdout: out
      ).call

      chunk_path = File.join(dir, "people_part_001.txt")
      assert File.file?(chunk_path)
      assert_includes File.read(chunk_path), "name:city"
    end
  end

  def test_workflow_uses_custom_output_directory_and_prefix
    out = StringIO.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.csv")
      output_dir = File.join(dir, "chunks")
      Dir.mkdir(output_dir)
      FileUtils.cp(fixture_path("split_people_25.csv"), source_path)
      input = [source_path, "", "", "10", output_dir, "batch", ""].join("\n") + "\n"

      Csvtool::Interface::CLI::Workflows::RunCsvSplitWorkflow.new(
        stdin: StringIO.new(input),
        stdout: out
      ).call

      assert File.file?(File.join(output_dir, "batch_part_001.csv"))
      assert File.file?(File.join(output_dir, "batch_part_002.csv"))
      assert File.file?(File.join(output_dir, "batch_part_003.csv"))
    end
  end

  def test_workflow_does_not_overwrite_existing_file_without_confirmation
    out = StringIO.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.csv")
      FileUtils.cp(fixture_path("split_people_25.csv"), source_path)
      existing = File.join(dir, "people_part_001.csv")
      File.write(existing, "sentinel\n")
      input = [source_path, "", "", "10", "", "", ""].join("\n") + "\n"

      Csvtool::Interface::CLI::Workflows::RunCsvSplitWorkflow.new(
        stdin: StringIO.new(input),
        stdout: out
      ).call

      assert_includes out.string, "Output file already exists: #{existing}"
      assert_equal "sentinel\n", File.read(existing)
    end
  end
end
