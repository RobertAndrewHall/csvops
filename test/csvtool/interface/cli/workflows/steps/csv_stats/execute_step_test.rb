# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/csv_stats/execute_step"

class CsvStatsExecuteStepTest < Minitest::Test
  Result = Struct.new(:ok, :data) do
    def ok? = ok
  end

  class FakeUseCase
    def initialize(result)
      @result = result
    end

    def call(session:)
      @result
    end
  end

  class FakePresenter
    attr_reader :summary_data, :written_path

    def print_summary(data)
      @summary_data = data
    end

    def print_file_written(path)
      @written_path = path
    end
  end

  def test_prints_summary_and_file_path_when_present
    presenter = FakePresenter.new
    result = Result.new(true, { row_count: 2, output_path: "/tmp/stats.csv" })
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvStats::ExecuteStep.new

    outcome = step.call(
      session: :session,
      use_case: FakeUseCase.new(result),
      presenter: presenter,
      handle_error: ->(_result) { raise "unexpected" }
    )

    assert_nil outcome
    assert_equal result.data, presenter.summary_data
    assert_equal "/tmp/stats.csv", presenter.written_path
  end

  def test_halts_on_use_case_failure
    fail_result = Result.new(false, { reason: :bad })
    handled = []
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvStats::ExecuteStep.new

    outcome = step.call(
      session: :session,
      use_case: FakeUseCase.new(fail_result),
      presenter: FakePresenter.new,
      handle_error: ->(result) { handled << result }
    )

    assert_equal :halt, outcome
    assert_equal [fail_result], handled
  end
end
