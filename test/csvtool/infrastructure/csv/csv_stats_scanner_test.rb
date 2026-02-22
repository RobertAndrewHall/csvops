# frozen_string_literal: true

require_relative "../../../test_helper"
require "csv"
require "csvtool/infrastructure/csv/csv_stats_scanner"
require "tmpdir"

class CsvStatsScannerTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_scans_headers_mode_with_streaming_foreach
    source = fixture_path("sample_people_blanks.csv")
    csv = Object.new
    received = nil

    define_singleton_foreach(csv) do |path, headers:, col_sep:, &block|
      received = { path: path, headers: headers, col_sep: col_sep }
      ::CSV.foreach(path, headers: headers, col_sep: col_sep, &block)
    end

    result = Csvtool::Infrastructure::CSV::CsvStatsScanner.new(csv: csv).call(
      file_path: source,
      col_sep: ",",
      headers_present: true
    )

    assert_equal({ path: source, headers: true, col_sep: "," }, received)
    assert_equal 5, result[:row_count]
    assert_equal 2, result[:column_count]
    assert_equal ["name", "city"], result[:headers]
    assert_equal [
      { name: "name", blank_count: 2, non_blank_count: 3 },
      { name: "city", blank_count: 1, non_blank_count: 4 }
    ], result[:column_stats]
  end

  def test_scans_large_file_in_single_pass_shape
    Dir.mktmpdir do |dir|
      path = File.join(dir, "large.csv")
      File.open(path, "w") do |f|
        f.puts("id,value")
        20_000.times { |i| f.puts("#{i},v#{i}") }
      end

      result = Csvtool::Infrastructure::CSV::CsvStatsScanner.new.call(
        file_path: path,
        col_sep: ",",
        headers_present: true
      )

      assert_equal 20_000, result[:row_count]
      assert_equal 2, result[:column_count]
      assert_equal ["id", "value"], result[:headers]
      assert_equal [
        { name: "id", blank_count: 0, non_blank_count: 20_000 },
        { name: "value", blank_count: 0, non_blank_count: 20_000 }
      ], result[:column_stats]
    end
  end

  private

  def define_singleton_foreach(obj, &implementation)
    obj.define_singleton_method(:foreach, &implementation)
  end
end
