# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/confirm_prompt"

class ConfirmPromptTest < Minitest::Test
  class FakeErrors
    attr_reader :calls

    def initialize
      @calls = []
    end

    def canceled = @calls << :canceled
  end

  def test_calls_canceled_on_no
    errors = FakeErrors.new
    prompt = Csvtool::Interface::CLI::Prompts::ConfirmPrompt.new(stdin: StringIO.new("n\n"), stdout: StringIO.new, errors: errors)
    assert_equal false, prompt.call(%w[a b])
    assert_includes errors.calls, :canceled
  end
end
