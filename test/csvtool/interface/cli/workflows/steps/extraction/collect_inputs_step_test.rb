# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/extraction/collect_inputs_step"

class ExtractionCollectInputsStepTest < Minitest::Test
  Result = Struct.new(:ok, :data) do
    def ok? = ok
  end

  class FakeUseCase
    def initialize(result)
      @result = result
    end

    def read_headers(file_path:, col_sep:)
      @result
    end
  end

  def test_halts_when_separator_missing
    file_prompt = Object.new
    separator_prompt = Object.new
    selector_prompt = Object.new
    skip_prompt = Object.new
    def file_prompt.call = "/tmp/data.csv"
    def separator_prompt.call = nil

    step = Csvtool::Interface::CLI::Workflows::Steps::Extraction::CollectInputsStep.new(
      file_path_prompt: file_prompt,
      separator_prompt: separator_prompt,
      column_selector_prompt: selector_prompt,
      skip_blanks_prompt: skip_prompt
    )

    assert_equal :halt, step.call(
      use_case: FakeUseCase.new(Result.new(true, { headers: [] })),
      session_builder: Object.new,
      handle_error: ->(_r) {}
    )
  end

  def test_halts_when_header_read_fails
    file_prompt = Object.new
    separator_prompt = Object.new
    selector_prompt = Object.new
    skip_prompt = Object.new
    builder = Object.new
    handled = []
    def file_prompt.call = "/tmp/data.csv"
    def separator_prompt.call = ","

    step = Csvtool::Interface::CLI::Workflows::Steps::Extraction::CollectInputsStep.new(
      file_path_prompt: file_prompt,
      separator_prompt: separator_prompt,
      column_selector_prompt: selector_prompt,
      skip_blanks_prompt: skip_prompt
    )

    fail_result = Result.new(false, {})
    result = step.call(use_case: FakeUseCase.new(fail_result), session_builder: builder, handle_error: ->(r) { handled << r })

    assert_equal :halt, result
    assert_equal [fail_result], handled
  end
end
