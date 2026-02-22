# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/csv_split/build_session_step"

class BuildSessionStepTest < Minitest::Test
  class FakeBuilder
    attr_reader :params

    def call(**params)
      @params = params
      :session
    end
  end

  def test_builds_session_from_context
    builder = FakeBuilder.new
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvSplit::BuildSessionStep.new
    context = {
      session_builder: builder,
      file_path: "/tmp/data.csv",
      col_sep: ",",
      headers_present: true,
      chunk_size: 10,
      output_directory: "/tmp/out",
      file_prefix: "batch",
      overwrite_existing: true,
      write_manifest: true,
      manifest_path: "/tmp/out/manifest.csv"
    }

    result = step.call(context)

    assert_nil result
    assert_equal :session, context[:session]
    assert_equal "/tmp/data.csv", builder.params[:file_path]
    assert_equal true, builder.params[:write_manifest]
    assert_equal "/tmp/out/manifest.csv", builder.params[:manifest_path]
  end
end
