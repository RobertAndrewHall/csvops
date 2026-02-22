# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/split_manifest_prompt"

class SplitManifestPromptTest < Minitest::Test
  class FakeYesNoPrompt
    def initialize(value)
      @value = value
    end

    def call(label:, default:)
      @value.nil? ? default : @value
    end
  end

  def test_returns_disabled_when_user_declines_manifest
    prompt = Csvtool::Interface::CLI::Prompts::SplitManifestPrompt.new(
      stdin: StringIO.new,
      stdout: StringIO.new,
      yes_no_prompt: FakeYesNoPrompt.new(false)
    )

    result = prompt.call(default_path: "/tmp/manifest.csv")

    assert_equal false, result[:write_manifest]
    assert_nil result[:manifest_path]
  end

  def test_uses_default_manifest_path_when_blank
    prompt = Csvtool::Interface::CLI::Prompts::SplitManifestPrompt.new(
      stdin: StringIO.new("\n"),
      stdout: StringIO.new,
      yes_no_prompt: FakeYesNoPrompt.new(true)
    )

    result = prompt.call(default_path: "/tmp/manifest.csv")

    assert_equal true, result[:write_manifest]
    assert_equal "/tmp/manifest.csv", result[:manifest_path]
  end
end
