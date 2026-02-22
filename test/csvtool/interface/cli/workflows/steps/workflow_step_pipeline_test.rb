# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/workflow_step_pipeline"

class WorkflowStepPipelineTest < Minitest::Test
  def test_runs_all_steps_when_no_halt
    calls = []
    step_1 = ->(_ctx) { calls << :one; nil }
    step_2 = ->(_ctx) { calls << :two; nil }
    pipeline = Csvtool::Interface::CLI::Workflows::Steps::WorkflowStepPipeline.new(steps: [step_1, step_2])

    result = pipeline.call({})

    assert_equal true, result
    assert_equal %i[one two], calls
  end

  def test_stops_on_halt
    calls = []
    step_1 = ->(_ctx) { calls << :one; :halt }
    step_2 = ->(_ctx) { calls << :two; nil }
    pipeline = Csvtool::Interface::CLI::Workflows::Steps::WorkflowStepPipeline.new(steps: [step_1, step_2])

    result = pipeline.call({})

    assert_equal false, result
    assert_equal [:one], calls
  end
end
