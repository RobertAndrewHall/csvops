# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/output/csv_randomized_row_file_writer"
require "tmpdir"

class InfrastructureCsvRandomizedRowFileWriterTest < Minitest::Test
  class FakeRandomizer
    def each(file_path:, col_sep:, headers:, seed:)
      yield ["Bob", "Paris"]
      yield ["Cara", "Berlin"]
    end
  end

  def test_writes_randomized_rows_with_headers
    writer = Csvtool::Infrastructure::Output::CsvRandomizedRowFileWriter.new(row_randomizer: FakeRandomizer.new)

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "randomized.csv")
      writer.call(
        path: output_path,
        headers: ["name", "city"],
        file_path: "ignored.csv",
        col_sep: ",",
        headers_present: true,
        seed: 123
      )

      assert_equal "name,city\nBob,Paris\nCara,Berlin\n", File.read(output_path)
    end
  end
end
