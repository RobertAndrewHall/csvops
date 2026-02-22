# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/prompts/dedupe_key_selector_prompt"

class DedupeKeySelectorPromptTest < Minitest::Test
  def test_builds_name_selector_in_header_mode
    prompt = Csvtool::Interface::CLI::Prompts::DedupeKeySelectorPrompt.new(stdin: StringIO.new("customer_id\n"), stdout: StringIO.new)

    selector = prompt.call(label: "Source", headers_present: true)

    assert_equal true, selector.headers_present?
    assert_equal "customer_id", selector.value
  end

  def test_builds_index_selector_in_headerless_mode
    prompt = Csvtool::Interface::CLI::Prompts::DedupeKeySelectorPrompt.new(stdin: StringIO.new("2\n"), stdout: StringIO.new)

    selector = prompt.call(label: "Reference", headers_present: false)

    assert_equal true, selector.index?
    assert_equal 2, selector.value
  end

  def test_returns_nil_for_invalid_selector
    prompt = Csvtool::Interface::CLI::Prompts::DedupeKeySelectorPrompt.new(stdin: StringIO.new("\n"), stdout: StringIO.new)

    assert_nil prompt.call(label: "Source", headers_present: true)
  end
end
