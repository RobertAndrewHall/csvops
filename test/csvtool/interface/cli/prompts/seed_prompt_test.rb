# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/seed_prompt"

class SeedPromptTest < Minitest::Test
  class FakeErrors
    attr_reader :calls

    def initialize
      @calls = []
    end

    def invalid_seed
      @calls << :invalid_seed
    end
  end

  def test_blank_returns_nil
    errors = FakeErrors.new
    prompt = Csvtool::Interface::CLI::Prompts::SeedPrompt.new(stdin: StringIO.new("\n"), stdout: StringIO.new, errors: errors)
    assert_nil prompt.call
    assert_empty errors.calls
  end

  def test_integer_returns_seed
    errors = FakeErrors.new
    prompt = Csvtool::Interface::CLI::Prompts::SeedPrompt.new(stdin: StringIO.new("42\n"), stdout: StringIO.new, errors: errors)
    assert_equal 42, prompt.call
    assert_empty errors.calls
  end

  def test_invalid_reports_error
    errors = FakeErrors.new
    prompt = Csvtool::Interface::CLI::Prompts::SeedPrompt.new(stdin: StringIO.new("abc\n"), stdout: StringIO.new, errors: errors)
    assert_equal Csvtool::Interface::CLI::Prompts::SeedPrompt::INVALID, prompt.call
    assert_includes errors.calls, :invalid_seed
  end
end
