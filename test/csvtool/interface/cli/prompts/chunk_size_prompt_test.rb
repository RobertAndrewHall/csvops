# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/chunk_size_prompt"

class ChunkSizePromptTest < Minitest::Test
  def test_returns_entered_value
    out = StringIO.new
    prompt = Csvtool::Interface::CLI::Prompts::ChunkSizePrompt.new(
      stdin: StringIO.new("25\n"),
      stdout: out
    )

    assert_equal "25", prompt.call
    assert_includes out.string, "Rows per chunk: "
  end
end
