# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/csv_split/collect_manifest_step"

class CollectManifestStepTest < Minitest::Test
  class FakeSplitManifestPrompt
    attr_reader :default_path

    def call(default_path:)
      @default_path = default_path
      { write_manifest: true, manifest_path: "/tmp/out/custom_manifest.csv" }
    end
  end

  def test_sets_manifest_values_in_context
    prompt = FakeSplitManifestPrompt.new
    step = Csvtool::Interface::CLI::Workflows::Steps::CsvSplit::CollectManifestStep.new(
      split_manifest_prompt: prompt
    )
    context = { output_directory: "/tmp/out", file_prefix: "batch" }

    result = step.call(context)

    assert_nil result
    assert_equal "/tmp/out/batch_manifest.csv", prompt.default_path
    assert_equal true, context[:write_manifest]
    assert_equal "/tmp/out/custom_manifest.csv", context[:manifest_path]
  end
end
