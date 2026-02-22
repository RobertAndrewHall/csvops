# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_csv_split"
require "csvtool/domain/csv_split_session/split_source"
require "csvtool/domain/csv_split_session/split_options"
require "csvtool/domain/csv_split_session/split_session"
require "tmpdir"
require "fileutils"

class RunCsvSplitTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_splits_25_rows_into_10_10_5_with_headers
    use_case = Csvtool::Application::UseCases::RunCsvSplit.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.csv")
      FileUtils.cp(fixture_path("split_people_25.csv"), source_path)

      source = Csvtool::Domain::CsvSplitSession::SplitSource.new(path: source_path, separator: ",", headers_present: true)
      options = Csvtool::Domain::CsvSplitSession::SplitOptions.new(chunk_size: 10)
      session = Csvtool::Domain::CsvSplitSession::SplitSession.start(source: source, options: options)

      result = use_case.call(session: session)

      assert result.ok?
      assert_equal 3, result.data[:chunk_count]
      assert_equal 25, result.data[:data_rows]
      assert_equal 3, result.data[:chunk_paths].length

      chunk_1 = File.read(result.data[:chunk_paths][0]).lines.map(&:strip)
      chunk_2 = File.read(result.data[:chunk_paths][1]).lines.map(&:strip)
      chunk_3 = File.read(result.data[:chunk_paths][2]).lines.map(&:strip)

      assert_equal 11, chunk_1.length
      assert_equal 11, chunk_2.length
      assert_equal 6, chunk_3.length
      assert_equal "name,city", chunk_1.first
      assert_equal "name,city", chunk_2.first
      assert_equal "name,city", chunk_3.first
      assert_equal "Name01,City01", chunk_1[1]
      assert_equal "Name10,City10", chunk_1[10]
      assert_equal "Name11,City11", chunk_2[1]
      assert_equal "Name20,City20", chunk_2[10]
      assert_equal "Name21,City21", chunk_3[1]
      assert_equal "Name25,City25", chunk_3[5]
    end
  end
end
