# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/builders/csv_split_session_builder"

class CsvSplitSessionBuilderTest < Minitest::Test
  def test_builds_split_session
    session = Csvtool::Interface::CLI::Workflows::Builders::CsvSplitSessionBuilder.new.call(
      file_path: "/tmp/people.csv",
      col_sep: ",",
      headers_present: true,
      chunk_size: 10,
      output_directory: "/tmp/out",
      file_prefix: "batch",
      overwrite_existing: true,
      write_manifest: true,
      manifest_path: "/tmp/out/manifest.csv"
    )

    assert_equal "/tmp/people.csv", session.source.path
    assert_equal ",", session.source.separator
    assert_equal true, session.source.headers_present
    assert_equal 10, session.options.chunk_size
    assert_equal "/tmp/out", session.options.output_directory
    assert_equal "batch", session.options.file_prefix
    assert_equal true, session.options.overwrite_existing
    assert_equal true, session.options.write_manifest
    assert_equal "/tmp/out/manifest.csv", session.options.manifest_path
  end
end
