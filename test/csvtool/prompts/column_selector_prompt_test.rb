# frozen_string_literal: true

require_relative "../../test_helper"
require "csvtool/prompts/column_selector_prompt"

class ColumnSelectorPromptTest < Minitest::Test
  class FakeErrors
    attr_reader :calls

    def initialize
      @calls = []
    end

    def column_not_found = @calls << :column_not_found
  end

  def test_selects_filtered_header
    errors = FakeErrors.new
    prompt = Csvtool::Prompts::ColumnSelectorPrompt.new(stdin: StringIO.new("ci\n1\n"), stdout: StringIO.new, errors: errors)
    assert_equal "city", prompt.call(%w[name city])
    assert_empty errors.calls
  end
end
