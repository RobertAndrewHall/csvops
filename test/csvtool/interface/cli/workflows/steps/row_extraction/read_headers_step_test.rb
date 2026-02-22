# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/row_extraction/read_headers_step"

class ReadHeadersStepTest < Minitest::Test
  Result = Struct.new(:ok, :data) do
    def ok? = ok
  end

  class FakeUseCase
    def initialize(result)
      @result = result
    end

    def read_headers(file_path:, col_sep:)
      @file_path = file_path
      @col_sep = col_sep
      @result
    end

    attr_reader :file_path, :col_sep
  end

  def test_sets_headers_on_success
    use_case = FakeUseCase.new(Result.new(true, { headers: ["name", "city"] }))
    step = Csvtool::Interface::CLI::Workflows::Steps::RowExtraction::ReadHeadersStep.new
    context = {
      use_case: use_case,
      file_path: "/tmp/data.csv",
      col_sep: ",",
      handle_error: ->(_result) { raise "should not be called" }
    }

    result = step.call(context)

    assert_nil result
    assert_equal ["name", "city"], context[:headers]
  end

  def test_halts_and_routes_error_when_failure
    failing_result = Result.new(false, {})
    use_case = FakeUseCase.new(failing_result)
    handled = []
    step = Csvtool::Interface::CLI::Workflows::Steps::RowExtraction::ReadHeadersStep.new

    result = step.call(
      use_case: use_case,
      file_path: "/tmp/data.csv",
      col_sep: ",",
      handle_error: ->(r) { handled << r }
    )

    assert_equal :halt, result
    assert_equal [failing_result], handled
  end
end
