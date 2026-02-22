# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/parity/build_session_step"

class ParityBuildSessionStepTest < Minitest::Test
  class FakeBuilder
    attr_reader :args

    def call(left_path:, right_path:, col_sep:, headers_present:)
      @args = {
        left_path: left_path,
        right_path: right_path,
        col_sep: col_sep,
        headers_present: headers_present
      }
      :session
    end
  end

  def test_builds_session_from_context
    builder = FakeBuilder.new
    step = Csvtool::Interface::CLI::Workflows::Steps::Parity::BuildSessionStep.new
    context = {
      session_builder: builder,
      left_path: "/tmp/left.csv",
      right_path: "/tmp/right.csv",
      col_sep: "\t",
      headers_present: false
    }

    result = step.call(context)

    assert_nil result
    assert_equal :session, context[:session]
    assert_equal "/tmp/left.csv", builder.args[:left_path]
    assert_equal "/tmp/right.csv", builder.args[:right_path]
    assert_equal "\t", builder.args[:col_sep]
    assert_equal false, builder.args[:headers_present]
  end
end
