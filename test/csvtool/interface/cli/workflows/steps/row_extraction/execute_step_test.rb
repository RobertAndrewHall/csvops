# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/row_extraction/execute_step"

class ExecuteStepTest < Minitest::Test
  Result = Struct.new(:ok, :data) do
    def ok? = ok
  end

  class FakeUseCase
    def initialize(result)
      @result = result
    end

    def extract(session:, headers:, on_row:)
      @called = true
      on_row.call(["Bob", "Paris"]) if @result.ok?
      @result
    end

    attr_reader :called
  end

  class FakePresenter
    attr_reader :rows, :written

    def initialize(stdout:, headers:, col_sep:)
      @rows = []
      @written = nil
    end

    def print_row(fields)
      @rows << fields
    end

    def print_file_written(path)
      @written = path
    end
  end

  class FakeErrors
    attr_reader :out_of_bounds

    def row_range_out_of_bounds(count)
      @out_of_bounds = count
    end
  end

  def test_prints_rows_and_reports_out_of_bounds
    errors = FakeErrors.new
    step = Csvtool::Interface::CLI::Workflows::Steps::RowExtraction::ExecuteStep.new(
      stdout: StringIO.new,
      errors: errors,
      presenter_class: FakePresenter
    )
    use_case = FakeUseCase.new(Result.new(true, { matched: false, row_count: 3, wrote_rows: false }))
    context = {
      session: Object.new,
      headers: ["name", "city"],
      use_case: use_case,
      handle_error: ->(_r) { raise "unexpected" }
    }

    result = step.call(context)

    assert_nil result
    assert_equal 3, errors.out_of_bounds
  end

  def test_halts_on_use_case_failure
    handled = []
    step = Csvtool::Interface::CLI::Workflows::Steps::RowExtraction::ExecuteStep.new(
      stdout: StringIO.new,
      errors: FakeErrors.new,
      presenter_class: FakePresenter
    )
    fail_result = Result.new(false, {})
    use_case = FakeUseCase.new(fail_result)

    result = step.call(
      session: Object.new,
      headers: ["name", "city"],
      use_case: use_case,
      handle_error: ->(r) { handled << r }
    )

    assert_equal :halt, result
    assert_equal [fail_result], handled
  end
end
