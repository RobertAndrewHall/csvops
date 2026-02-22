# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/output/csv_stats_file_writer"
require "tmpdir"

class InfrastructureCsvStatsFileWriterTest < Minitest::Test
  def test_writes_stats_as_metric_value_csv
    writer = Csvtool::Infrastructure::Output::CsvStatsFileWriter.new

    Dir.mktmpdir do |dir|
      path = File.join(dir, "stats.csv")
      writer.call(
        path: path,
        data: {
          row_count: 3,
          column_count: 2,
          headers: ["name", "city"],
          column_stats: [
            { name: "name", non_blank_count: 3, blank_count: 0 },
            { name: "city", non_blank_count: 2, blank_count: 1 }
          ]
        }
      )

      assert_equal [
        "metric,value",
        "row_count,3",
        "column_count,2",
        "headers,name|city",
        "column.name.non_blank,3",
        "column.name.blank,0",
        "column.city.non_blank,2",
        "column.city.blank,1"
      ], File.read(path).lines.map(&:strip)
    end
  end
end
