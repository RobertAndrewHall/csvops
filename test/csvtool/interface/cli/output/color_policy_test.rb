# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/output/color_policy"

class ColorPolicyTest < Minitest::Test
  class TtyIO
    def tty? = true
  end

  class NonTtyIO
    def tty? = false
  end

  def test_auto_uses_tty
    enabled = Csvtool::Interface::CLI::Output::ColorPolicy.new(mode: "auto", io: TtyIO.new, env: {}).enabled?
    disabled = Csvtool::Interface::CLI::Output::ColorPolicy.new(mode: "auto", io: NonTtyIO.new, env: {}).enabled?

    assert_equal true, enabled
    assert_equal false, disabled
  end

  def test_never_disables_color
    policy = Csvtool::Interface::CLI::Output::ColorPolicy.new(mode: "never", io: TtyIO.new, env: {})

    assert_equal false, policy.enabled?
  end

  def test_always_enables_color_even_with_no_color
    policy = Csvtool::Interface::CLI::Output::ColorPolicy.new(mode: "always", io: NonTtyIO.new, env: { "NO_COLOR" => "1" })

    assert_equal true, policy.enabled?
  end

  def test_no_color_disables_auto
    policy = Csvtool::Interface::CLI::Output::ColorPolicy.new(mode: "auto", io: TtyIO.new, env: { "NO_COLOR" => "1" })

    assert_equal false, policy.enabled?
  end
end
