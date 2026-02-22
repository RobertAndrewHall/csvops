# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/csv_split/collect_inputs_step"

class CollectInputsStepTest < Minitest::Test
  class FakePrompt
    def initialize(value)
      @value = value
    end

    def call(label: nil)
      @value
    end
  end

  class FakeErrors
    attr_reader :invalid_chunk_size_calls

    def initialize
      @invalid_chunk_size_calls = 0
    end

    def invalid_chunk_size
      @invalid_chunk_size_calls += 1
    end
  end

  def test_collects_inputs_into_context
    errors = FakeErrors.new
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvSplit::CollectInputsStep.new(
      file_path_prompt: FakePrompt.new("/tmp/data.csv"),
      separator_prompt: FakePrompt.new(","),
      headers_present_prompt: FakePrompt.new(true),
      chunk_size_prompt: FakePrompt.new("10"),
      errors: errors
    )
    context = {}

    result = step.call(context)

    assert_nil result
    assert_equal "/tmp/data.csv", context[:file_path]
    assert_equal ",", context[:col_sep]
    assert_equal true, context[:headers_present]
    assert_equal 10, context[:chunk_size]
  end

  def test_halts_on_invalid_chunk_size
    errors = FakeErrors.new
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvSplit::CollectInputsStep.new(
      file_path_prompt: FakePrompt.new("/tmp/data.csv"),
      separator_prompt: FakePrompt.new(","),
      headers_present_prompt: FakePrompt.new(true),
      chunk_size_prompt: FakePrompt.new("abc"),
      errors: errors
    )

    result = step.call({})

    assert_equal :halt, result
    assert_equal 1, errors.invalid_chunk_size_calls
  end
end
