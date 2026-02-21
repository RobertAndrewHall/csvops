# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/skip_blanks_prompt"

class SkipBlanksPromptTest < Minitest::Test
  def test_default_true_and_no_false
    prompt_yes = Csvtool::Interface::CLI::Prompts::SkipBlanksPrompt.new(stdin: StringIO.new("\n"), stdout: StringIO.new)
    prompt_no = Csvtool::Interface::CLI::Prompts::SkipBlanksPrompt.new(stdin: StringIO.new("n\n"), stdout: StringIO.new)
    assert_equal true, prompt_yes.call
    assert_equal false, prompt_no.call
  end
end
