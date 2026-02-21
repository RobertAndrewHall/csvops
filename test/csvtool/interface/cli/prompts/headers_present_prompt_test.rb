# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/headers_present_prompt"

class HeadersPresentPromptTest < Minitest::Test
  def test_defaults_to_true_and_accepts_negative_inputs
    yes_prompt = Csvtool::Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: StringIO.new("\n"), stdout: StringIO.new)
    no_prompt = Csvtool::Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: StringIO.new("n\n"), stdout: StringIO.new)

    assert_equal true, yes_prompt.call
    assert_equal false, no_prompt.call
  end
end
