# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/output/csv_row_console_writer"

class InfrastructureCsvRowConsoleWriterTest < Minitest::Test
  class FakeRowStreamer
    def each_in_range(file_path:, col_sep:, start_row:, end_row:)
      yield ["Bob", "Paris"]
      yield ["Cara", "Berlin"]
      { matched: true, row_count: 3 }
    end
  end

  def test_writes_header_and_rows_to_stdout
    out = StringIO.new
    writer = Csvtool::Infrastructure::Output::CsvRowConsoleWriter.new(stdout: out, row_streamer: FakeRowStreamer.new)

    stats = writer.call(file_path: "x.csv", col_sep: ",", headers: ["name", "city"], start_row: 2, end_row: 3)

    assert_equal "name,city\nBob,Paris\nCara,Berlin\n", out.string
    assert_equal true, stats[:matched]
  end
end
