# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/output/csv_split_manifest_writer"
require "tmpdir"

class CsvSplitManifestWriterTest < Minitest::Test
  def test_writes_manifest_csv
    writer = Csvtool::Infrastructure::Output::CsvSplitManifestWriter.new

    Dir.mktmpdir do |dir|
      path = File.join(dir, "manifest.csv")
      writer.call(
        path: path,
        chunk_paths: ["/tmp/a.csv", "/tmp/b.csv"],
        chunk_row_counts: [10, 5]
      )

      lines = File.read(path).lines.map(&:strip)
      assert_equal "chunk_index,chunk_path,row_count", lines[0]
      assert_equal "1,/tmp/a.csv,10", lines[1]
      assert_equal "2,/tmp/b.csv,5", lines[2]
    end
  end
end
