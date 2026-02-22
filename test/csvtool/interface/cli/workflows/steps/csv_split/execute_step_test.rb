# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/csv_split/execute_step"

class SplitExecuteStepTest < Minitest::Test
  Result = Struct.new(:ok, :data) do
    def ok? = ok
  end

  class FakeUseCase
    def initialize(headers_result:, run_result:)
      @headers_result = headers_result
      @run_result = run_result
    end

    def read_headers(file_path:, col_sep:, headers_present:)
      @headers_called = [file_path, col_sep, headers_present]
      @headers_result
    end

    def call(session:)
      @session = session
      @run_result
    end

    attr_reader :headers_called, :session
  end

  class FakePresenter
    attr_reader :summary

    def print_summary(data)
      @summary = data
    end
  end

  def test_handles_header_failure
    headers_fail = Result.new(false, { path: "/tmp/missing.csv" })
    use_case = FakeUseCase.new(headers_result: headers_fail, run_result: Result.new(true, {}))
    handled = []
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvSplit::ExecuteStep.new

    result = step.call(
      file_path: "/tmp/missing.csv",
      col_sep: ",",
      headers_present: true,
      chunk_size: 10,
      use_case: use_case,
      session: Object.new,
      presenter: FakePresenter.new,
      handle_error: ->(r) { handled << r }
    )

    assert_equal :halt, result
    assert_equal [headers_fail], handled
  end

  def test_prints_summary_on_success
    use_case = FakeUseCase.new(
      headers_result: Result.new(true, { headers: %w[name city] }),
      run_result: Result.new(true, { chunk_count: 3, chunk_paths: ["/tmp/a.csv"], data_rows: 25 })
    )
    presenter = FakePresenter.new
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvSplit::ExecuteStep.new

    result = step.call(
      file_path: "/tmp/people.csv",
      col_sep: ",",
      headers_present: true,
      chunk_size: 10,
      use_case: use_case,
      session: :session,
      presenter: presenter,
      handle_error: ->(_r) { raise "unexpected" }
    )

    assert_nil result
    assert_equal :session, use_case.session
    assert_equal 10, presenter.summary[:chunk_size]
    assert_equal 3, presenter.summary[:chunk_count]
  end
end
