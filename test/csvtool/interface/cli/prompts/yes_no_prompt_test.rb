# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/yes_no_prompt"

class YesNoPromptTest < Minitest::Test
  def test_uses_default_for_blank_or_invalid
    prompt_blank = Csvtool::Interface::CLI::Prompts::YesNoPrompt.new(stdin: StringIO.new("\n"), stdout: StringIO.new)
    prompt_invalid = Csvtool::Interface::CLI::Prompts::YesNoPrompt.new(stdin: StringIO.new("maybe\n"), stdout: StringIO.new)

    assert_equal true, prompt_blank.call(label: "Q? ", default: true)
    assert_equal false, prompt_invalid.call(label: "Q? ", default: false)
  end

  def test_accepts_yes_and_no_inputs
    prompt_yes = Csvtool::Interface::CLI::Prompts::YesNoPrompt.new(stdin: StringIO.new("y\n"), stdout: StringIO.new)
    prompt_no = Csvtool::Interface::CLI::Prompts::YesNoPrompt.new(stdin: StringIO.new("no\n"), stdout: StringIO.new)

    assert_equal true, prompt_yes.call(label: "Q? ", default: false)
    assert_equal false, prompt_no.call(label: "Q? ", default: true)
  end
end
