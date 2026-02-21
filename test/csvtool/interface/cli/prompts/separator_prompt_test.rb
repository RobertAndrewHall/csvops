# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/separator_prompt"

class SeparatorPromptTest < Minitest::Test
  class FakeErrors
    attr_reader :calls

    def initialize
      @calls = []
    end

    def empty_custom_separator = @calls << :empty_custom_separator
    def invalid_separator_choice = @calls << :invalid_separator_choice
  end

  def test_defaults_to_comma
    errors = FakeErrors.new
    prompt = Csvtool::Interface::CLI::Prompts::SeparatorPrompt.new(stdin: StringIO.new("\n"), stdout: StringIO.new, errors: errors)
    assert_equal ",", prompt.call
    assert_empty errors.calls
  end

  def test_custom_empty_reports_error
    errors = FakeErrors.new
    prompt = Csvtool::Interface::CLI::Prompts::SeparatorPrompt.new(stdin: StringIO.new("5\n\n"), stdout: StringIO.new, errors: errors)
    assert_nil prompt.call
    assert_includes errors.calls, :empty_custom_separator
  end
end
