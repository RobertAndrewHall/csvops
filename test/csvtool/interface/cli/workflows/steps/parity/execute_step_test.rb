# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/parity/execute_step"

class ParityExecuteStepTest < Minitest::Test
  Result = Struct.new(:ok, :data) do
    def ok? = ok
  end

  class FakeUseCase
    attr_reader :session

    def call(session:)
      @session = session
      Result.new(true, { match: true })
    end
  end

  class FakePresenter
    attr_reader :data

    def print_summary(data)
      @data = data
    end
  end

  def test_calls_use_case_and_presenter
    step = Csvtool::Interface::CLI::Workflows::Steps::Parity::ExecuteStep.new
    use_case = FakeUseCase.new
    presenter = FakePresenter.new
    context = { use_case: use_case, session: :session, presenter: presenter, handle_error: ->(_r) {} }

    result = step.call(context)

    assert_nil result
    assert_equal :session, use_case.session
    assert_equal true, presenter.data[:match]
  end
end
