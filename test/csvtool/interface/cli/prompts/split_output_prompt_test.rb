# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/split_output_prompt"
require "csvtool/interface/cli/prompts/yes_no_prompt"

class SplitOutputPromptTest < Minitest::Test
  def test_uses_defaults_for_blank_values
    out = StringIO.new
    prompt = Csvtool::Interface::CLI::Prompts::SplitOutputPrompt.new(
      stdin: StringIO.new("\n\n\n"),
      stdout: out,
      yes_no_prompt: Csvtool::Interface::CLI::Prompts::YesNoPrompt.new(stdin: StringIO.new("\n"), stdout: StringIO.new)
    )

    result = prompt.call(default_directory: "/tmp/out", default_prefix: "people")

    assert_equal "/tmp/out", result[:output_directory]
    assert_equal "people", result[:file_prefix]
    assert_equal false, result[:overwrite_existing]
  end
end
