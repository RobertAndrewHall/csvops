# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/workflows/run_row_randomization_workflow"
require "tmpdir"

class RunRowRandomizationWorkflowTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../../fixtures/#{name}", __dir__)
  end

  def test_missing_file_shows_friendly_error
    output = StringIO.new
    input = StringIO.new("/tmp/does-not-exist.csv\n\n")

    Csvtool::Interface::CLI::Workflows::RunRowRandomizationWorkflow.new(stdin: input, stdout: output).call

    assert_includes output.string, "File not found: /tmp/does-not-exist.csv"
  end

  def test_workflow_prints_header_then_all_randomized_rows
    output = StringIO.new
    input = StringIO.new([fixture_path("sample_people.csv"), "", "", "", ""].join("\n") + "\n")

    Csvtool::Interface::CLI::Workflows::RunRowRandomizationWorkflow.new(stdin: input, stdout: output).call

    assert_includes output.string, "name,city"
    assert_includes output.string, "Alice,London"
    assert_includes output.string, "Bob,Paris"
    assert_includes output.string, "Cara,Berlin"
  end

  def test_workflow_can_write_randomized_rows_to_file
    output = StringIO.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "randomized.csv")
      input = StringIO.new([fixture_path("sample_people.csv"), "", "", "", "2", output_path].join("\n") + "\n")

      Csvtool::Interface::CLI::Workflows::RunRowRandomizationWorkflow.new(stdin: input, stdout: output).call

      written = File.read(output_path).lines.map(&:strip)
      assert_equal "name,city", written.first
      assert_equal ["Alice,London", "Bob,Paris", "Cara,Berlin"].sort, written[1..].sort
      assert_includes output.string, "Wrote output to #{output_path}"
    end
  end

  def test_workflow_supports_headerless_mode
    output = StringIO.new
    input = StringIO.new([fixture_path("sample_people_no_headers.csv"), "", "n", "", ""].join("\n") + "\n")

    Csvtool::Interface::CLI::Workflows::RunRowRandomizationWorkflow.new(stdin: input, stdout: output).call

    refute_includes output.string, "name,city"
    assert_includes output.string, "Alice,London"
    assert_includes output.string, "Bob,Paris"
    assert_includes output.string, "Cara,Berlin"
  end

  def test_invalid_seed_shows_friendly_error
    output = StringIO.new
    input = StringIO.new([fixture_path("sample_people.csv"), "", "", "abc"].join("\n") + "\n")

    Csvtool::Interface::CLI::Workflows::RunRowRandomizationWorkflow.new(stdin: input, stdout: output).call

    assert_includes output.string, "Seed must be an integer."
  end
end
