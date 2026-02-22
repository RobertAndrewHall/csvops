# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/parity/collect_inputs_step"

class ParityCollectInputsStepTest < Minitest::Test
  def test_collects_inputs_into_context
    file_prompt = Object.new
    separator_prompt = Object.new
    headers_prompt = Object.new
    def file_prompt.call(label:) = label.include?("Left") ? "/tmp/left.csv" : "/tmp/right.csv"
    def separator_prompt.call = ","
    def headers_prompt.call = true

    step = Csvtool::Interface::CLI::Workflows::Steps::Parity::CollectInputsStep.new(
      file_path_prompt: file_prompt,
      separator_prompt: separator_prompt,
      headers_present_prompt: headers_prompt
    )
    context = {}

    result = step.call(context)

    assert_nil result
    assert_equal "/tmp/left.csv", context[:left_path]
    assert_equal "/tmp/right.csv", context[:right_path]
    assert_equal ",", context[:col_sep]
    assert_equal true, context[:headers_present]
  end
end
