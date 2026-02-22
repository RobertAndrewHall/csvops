# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/csv_stats/collect_destination_step"

class CsvStatsCollectDestinationStepTest < Minitest::Test
  class FakePrompt
    def initialize(result)
      @result = result
    end

    def call
      @result
    end
  end

  class FakeMapper
    attr_reader :input

    def call(input)
      @input = input
      :mapped_destination
    end
  end

  def test_collects_and_maps_destination
    mapper = FakeMapper.new
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvStats::CollectDestinationStep.new(
      output_destination_prompt: FakePrompt.new({ mode: :file, path: "/tmp/out.csv" })
    )
    context = { output_destination_mapper: mapper }

    result = step.call(context)

    assert_nil result
    assert_equal({ mode: :file, path: "/tmp/out.csv" }, mapper.input)
    assert_equal :mapped_destination, context[:output_destination]
  end

  def test_halts_when_destination_prompt_returns_nil
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvStats::CollectDestinationStep.new(
      output_destination_prompt: FakePrompt.new(nil)
    )

    result = step.call(output_destination_mapper: FakeMapper.new)

    assert_equal :halt, result
  end
end
