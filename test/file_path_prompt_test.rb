# frozen_string_literal: true

require_relative "test_helper"
require "csvtool/prompts/file_path_prompt"

class FilePathPromptTest < Minitest::Test
  def test_returns_trimmed_path
    prompt = Csvtool::Prompts::FilePathPrompt.new(stdin: StringIO.new("  /tmp/a.csv  \n"), stdout: StringIO.new)
    assert_equal "/tmp/a.csv", prompt.call
  end
end
