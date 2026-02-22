# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/output/colorizer"

class ColorizerTest < Minitest::Test
  class FakePolicy
    def initialize(enabled)
      @enabled = enabled
    end

    def enabled?
      @enabled
    end
  end

  def test_wraps_text_when_enabled
    colorizer = Csvtool::Interface::CLI::Output::Colorizer.new(policy: FakePolicy.new(true))

    assert_equal "\e[31mMISMATCH\e[0m", colorizer.call("MISMATCH", code: "31")
  end

  def test_returns_text_when_disabled
    colorizer = Csvtool::Interface::CLI::Output::Colorizer.new(policy: FakePolicy.new(false))

    assert_equal "MATCH", colorizer.call("MATCH", code: "32")
  end
end
