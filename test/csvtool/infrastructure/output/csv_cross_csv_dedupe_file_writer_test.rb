# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/output/csv_cross_csv_dedupe_file_writer"
require "tmpdir"

class InfrastructureCsvCrossCsvDedupeFileWriterTest < Minitest::Test
  class FakeDeduper
    def each_retained(**_kwargs)
      yield %w[1 Alice]
      yield %w[3 Cara]
      { source_rows: 5, removed_rows: 3, kept_rows_count: 2 }
    end
  end

  def test_writes_retained_rows_and_returns_stats
    writer = Csvtool::Infrastructure::Output::CsvCrossCsvDedupeFileWriter.new(deduper: FakeDeduper.new)

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "deduped.csv")
      stats = writer.call(
        path: output_path,
        headers: ["customer_id", "name"],
        col_sep: ",",
        dedupe_options: { source_path: "source.csv", reference_path: "reference.csv" }
      )

      assert_equal "customer_id,name\n1,Alice\n3,Cara\n", File.read(output_path)
      assert_equal 2, stats[:kept_rows_count]
    end
  end
end
