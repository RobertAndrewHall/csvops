# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/row_extraction/collect_source_step"

class CollectSourceStepTest < Minitest::Test
  def test_collects_file_and_separator
    file_prompt = Object.new
    separator_prompt = Object.new
    def file_prompt.call = "/tmp/data.csv"
    def separator_prompt.call = ","

    step = Csvtool::Interface::CLI::Workflows::Steps::RowExtraction::CollectSourceStep.new(
      file_path_prompt: file_prompt,
      separator_prompt: separator_prompt
    )
    context = {}

    result = step.call(context)

    assert_nil result
    assert_equal "/tmp/data.csv", context[:file_path]
    assert_equal ",", context[:col_sep]
  end

  def test_halts_when_separator_missing
    file_prompt = Object.new
    separator_prompt = Object.new
    def file_prompt.call = "/tmp/data.csv"
    def separator_prompt.call = nil

    step = Csvtool::Interface::CLI::Workflows::Steps::RowExtraction::CollectSourceStep.new(
      file_path_prompt: file_prompt,
      separator_prompt: separator_prompt
    )

    assert_equal :halt, step.call({})
  end
end
