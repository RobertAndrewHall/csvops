# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/interface/cli/errors/presenter"

class OutputDestinationPromptTest < Minitest::Test
  def test_defaults_to_console
    stdout = StringIO.new
    prompt = Csvtool::Interface::CLI::Prompts::OutputDestinationPrompt.new(
      stdin: StringIO.new("\n"),
      stdout: stdout,
      errors: Csvtool::Interface::CLI::Errors::Presenter.new(stdout: stdout)
    )
    assert_equal({ mode: :console }, prompt.call)
  end

  def test_file_mode_requires_path
    stdout = StringIO.new
    prompt = Csvtool::Interface::CLI::Prompts::OutputDestinationPrompt.new(
      stdin: StringIO.new("2\n\n"),
      stdout: stdout,
      errors: Csvtool::Interface::CLI::Errors::Presenter.new(stdout: stdout)
    )
    assert_nil prompt.call
    assert_includes stdout.string, "Output file path cannot be empty."
  end
end
