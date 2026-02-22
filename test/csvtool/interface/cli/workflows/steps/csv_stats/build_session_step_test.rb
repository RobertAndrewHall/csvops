# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/csv_stats/build_session_step"

class CsvStatsBuildSessionStepTest < Minitest::Test
  class FakeBuilder
    attr_reader :params

    def call(**params)
      @params = params
      :session
    end
  end

  def test_builds_session_from_context
    builder = FakeBuilder.new
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvStats::BuildSessionStep.new
    context = {
      session_builder: builder,
      file_path: "/tmp/data.csv",
      col_sep: "\t",
      headers_present: true,
      output_destination: :destination
    }

    result = step.call(context)

    assert_nil result
    assert_equal :session, context[:session]
    assert_equal "/tmp/data.csv", builder.params[:file_path]
    assert_equal "\t", builder.params[:col_sep]
    assert_equal true, builder.params[:headers_present]
    assert_equal :destination, builder.params[:destination]
  end
end
