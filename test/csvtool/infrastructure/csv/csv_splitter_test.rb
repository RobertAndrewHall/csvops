# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/csv/csv_splitter"
require "tmpdir"

class CsvSplitterTest < Minitest::Test
  def test_splits_large_file_in_order
    splitter = Csvtool::Infrastructure::CSV::CsvSplitter.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "large.csv")
      File.open(source_path, "w") do |f|
        f.puts "id,value"
        5_000.times { |i| f.puts "#{i + 1},v#{i + 1}" }
      end

      stats = splitter.call(
        file_path: source_path,
        col_sep: ",",
        headers_present: true,
        chunk_size: 1_000,
        output_directory: dir,
        file_prefix: "large",
        overwrite_existing: false
      )

      assert_equal 5, stats[:chunk_count]
      assert_equal 5_000, stats[:data_rows]
      assert_equal [1_000, 1_000, 1_000, 1_000, 1_000], stats[:chunk_row_counts]

      first_chunk = File.read(File.join(dir, "large_part_001.csv")).lines.map(&:strip)
      last_chunk = File.read(File.join(dir, "large_part_005.csv")).lines.map(&:strip)
      assert_equal "id,value", first_chunk.first
      assert_equal "1,v1", first_chunk[1]
      assert_equal "1000,v1000", first_chunk[1000]
      assert_equal "4001,v4001", last_chunk[1]
      assert_equal "5000,v5000", last_chunk[1000]
    end
  end

  def test_streaming_split_handles_headerless_file
    splitter = Csvtool::Infrastructure::CSV::CsvSplitter.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "large_no_headers.csv")
      File.open(source_path, "w") do |f|
        2_500.times { |i| f.puts "#{i + 1},v#{i + 1}" }
      end

      stats = splitter.call(
        file_path: source_path,
        col_sep: ",",
        headers_present: false,
        chunk_size: 1_000,
        output_directory: dir,
        file_prefix: "large_no_headers",
        overwrite_existing: false
      )

      assert_equal 3, stats[:chunk_count]
      assert_equal 2_500, stats[:data_rows]
      assert_equal [1_000, 1_000, 500], stats[:chunk_row_counts]
      first_line = File.read(File.join(dir, "large_no_headers_part_001.csv")).lines.first.strip
      assert_equal "1,v1", first_line
    end
  end
end
