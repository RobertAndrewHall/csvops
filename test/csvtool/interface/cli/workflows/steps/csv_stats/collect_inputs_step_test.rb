# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/csv_stats/collect_inputs_step"

class CsvStatsCollectInputsStepTest < Minitest::Test
  class FakeFilePathPrompt
    attr_reader :label

    def call(label:)
      @label = label
      "/tmp/input.csv"
    end
  end

  class FakeSeparatorPrompt
    def initialize(result)
      @result = result
    end

    def call
      @result
    end
  end

  class FakeHeadersPresentPrompt
    def call
      false
    end
  end

  def test_collects_inputs_into_context
    file_prompt = FakeFilePathPrompt.new
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvStats::CollectInputsStep.new(
      file_path_prompt: file_prompt,
      separator_prompt: FakeSeparatorPrompt.new(";"),
      headers_present_prompt: FakeHeadersPresentPrompt.new
    )
    context = {}

    result = step.call(context)

    assert_nil result
    assert_equal "CSV file path: ", file_prompt.label
    assert_equal "/tmp/input.csv", context[:file_path]
    assert_equal ";", context[:col_sep]
    assert_equal false, context[:headers_present]
  end

  def test_halts_when_separator_prompt_returns_nil
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvStats::CollectInputsStep.new(
      file_path_prompt: FakeFilePathPrompt.new,
      separator_prompt: FakeSeparatorPrompt.new(nil),
      headers_present_prompt: FakeHeadersPresentPrompt.new
    )

    result = step.call({})

    assert_equal :halt, result
  end
end
