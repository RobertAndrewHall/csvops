# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/output/csv_row_file_writer"
require "tmpdir"

class InfrastructureCsvRowFileWriterTest < Minitest::Test
  class FakeRowStreamer
    def each_in_range(file_path:, col_sep:, start_row:, end_row:)
      yield ["Bob", "Paris"]
      yield ["Cara", "Berlin"]
      { matched: true, row_count: 3 }
    end
  end

  def test_writes_header_and_rows_to_file
    writer = Csvtool::Infrastructure::Output::CsvRowFileWriter.new(
      row_streamer: FakeRowStreamer.new
    )

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "rows.csv")
      stats = writer.call(
        file_path: "x.csv",
        col_sep: ",",
        headers: ["name", "city"],
        start_row: 2,
        end_row: 3,
        output_path: output_path
      )

      assert_equal "name,city\nBob,Paris\nCara,Berlin\n", File.read(output_path)
      assert_equal true, stats[:matched]
      assert_equal true, stats[:wrote_rows]
    end
  end
end
