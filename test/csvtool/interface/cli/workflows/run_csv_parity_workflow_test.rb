# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/workflows/run_csv_parity_workflow"

class RunCsvParityWorkflowTest < Minitest::Test
  class FakeUseCase
    attr_reader :calls

    def initialize
      @calls = []
    end

    def call(left_path:, right_path:, col_sep:, headers_present:)
      @calls << { left_path: left_path, right_path: right_path, col_sep: col_sep, headers_present: headers_present }
      Struct.new(:ok?, :data).new(true, {
        match: true,
        left_rows: 3,
        right_rows: 3,
        left_only_count: 0,
        right_only_count: 0
      })
    end
  end

  class MismatchUseCase
    def call(left_path:, right_path:, col_sep:, headers_present:)
      Struct.new(:ok?, :data).new(true, {
        match: false,
        left_rows: 3,
        right_rows: 3,
        left_only_count: 1,
        right_only_count: 1,
        left_only_examples: [{ row: "Cara,Berlin", count_delta: 1 }],
        right_only_examples: [{ row: "Dina,Rome", count_delta: 1 }]
      })
    end
  end

  def test_prompts_for_paths_and_calls_use_case
    stdout = StringIO.new
    use_case = FakeUseCase.new
    input = StringIO.new("/tmp/left.csv\n/tmp/right.csv\n2\ny\n")

    Csvtool::Interface::CLI::Workflows::RunCsvParityWorkflow
      .new(stdin: input, stdout: stdout, use_case: use_case)
      .call

    assert_equal [{ left_path: "/tmp/left.csv", right_path: "/tmp/right.csv", col_sep: "\t", headers_present: true }], use_case.calls
    assert_includes stdout.string, "Left CSV file path: "
    assert_includes stdout.string, "Right CSV file path: "
    assert_includes stdout.string, "Choose separator:"
    assert_includes stdout.string, "Headers present? [Y/n]: "
    assert_includes stdout.string, "MATCH"
    assert_includes stdout.string, "Summary: left_rows=3 right_rows=3 left_only=0 right_only=0"
  end

  def test_prints_mismatch_examples_when_not_equal
    stdout = StringIO.new
    input = StringIO.new("/tmp/left.csv\n/tmp/right.csv\n\ny\n")

    Csvtool::Interface::CLI::Workflows::RunCsvParityWorkflow
      .new(stdin: input, stdout: stdout, use_case: MismatchUseCase.new)
      .call

    assert_includes stdout.string, "MISMATCH"
    assert_includes stdout.string, "Left-only examples:"
    assert_includes stdout.string, "Cara,Berlin (count +1)"
    assert_includes stdout.string, "Right-only examples:"
    assert_includes stdout.string, "Dina,Rome (count +1)"
  end
end
