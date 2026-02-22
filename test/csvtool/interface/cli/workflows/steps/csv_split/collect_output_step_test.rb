# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/csv_split/collect_output_step"

class CollectOutputStepTest < Minitest::Test
  class FakeSplitOutputPrompt
    attr_reader :received

    def call(default_directory:, default_prefix:)
      @received = { default_directory: default_directory, default_prefix: default_prefix }
      { output_directory: "/tmp/out", file_prefix: "batch", overwrite_existing: true }
    end
  end

  def test_sets_output_values_in_context
    prompt = FakeSplitOutputPrompt.new
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvSplit::CollectOutputStep.new(
      split_output_prompt: prompt
    )
    context = { file_path: "/tmp/people.csv" }

    result = step.call(context)

    assert_nil result
    assert_equal "/tmp", prompt.received[:default_directory]
    assert_equal "people", prompt.received[:default_prefix]
    assert_equal "/tmp/out", context[:output_directory]
    assert_equal "batch", context[:file_prefix]
    assert_equal true, context[:overwrite_existing]
  end
end
