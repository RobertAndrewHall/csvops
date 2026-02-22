# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/row_randomization/collect_inputs_step"
require "csvtool/interface/cli/prompts/seed_prompt"

class RowRandomizationCollectInputsStepTest < Minitest::Test
  Result = Struct.new(:ok, :data) do
    def ok? = ok
  end

  class FakeUseCase
    def read_headers(file_path:, col_sep:, headers_present:)
      Result.new(true, { headers: ["name"] })
    end
  end

  def test_halts_when_seed_invalid
    file_prompt = Object.new
    separator_prompt = Object.new
    headers_prompt = Object.new
    seed_prompt = Object.new
    def file_prompt.call = "/tmp/data.csv"
    def separator_prompt.call = ","
    def headers_prompt.call = true
    def seed_prompt.call = Csvtool::Interface::CLI::Prompts::SeedPrompt::INVALID

    step = Csvtool::Interface::CLI::Workflows::Steps::RowRandomization::CollectInputsStep.new(
      file_path_prompt: file_prompt,
      separator_prompt: separator_prompt,
      headers_present_prompt: headers_prompt,
      seed_prompt: seed_prompt
    )

    assert_equal :halt, step.call(use_case: FakeUseCase.new, handle_error: ->(_r) {})
  end
end
