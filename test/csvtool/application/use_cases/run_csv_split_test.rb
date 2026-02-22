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

  def test_returns_output_file_exists_when_overwrite_is_disabled
    use_case = Csvtool::Application::UseCases::RunCsvSplit.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.csv")
      FileUtils.cp(fixture_path("split_people_25.csv"), source_path)
      File.write(File.join(dir, "people_part_001.csv"), "sentinel\n")

      source = Csvtool::Domain::CsvSplitSession::SplitSource.new(path: source_path, separator: ",", headers_present: true)
      options = Csvtool::Domain::CsvSplitSession::SplitOptions.new(chunk_size: 10, overwrite_existing: false)
      session = Csvtool::Domain::CsvSplitSession::SplitSession.start(source: source, options: options)

      result = use_case.call(session: session)

      refute result.ok?
      assert_equal :output_file_exists, result.error
      assert_equal File.join(dir, "people_part_001.csv"), result.data[:path]
    end
  end

  def test_creates_output_directory_when_it_does_not_exist
    use_case = Csvtool::Application::UseCases::RunCsvSplit.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.csv")
      output_dir = File.join(dir, "new_chunks")
      FileUtils.cp(fixture_path("split_people_25.csv"), source_path)

      source = Csvtool::Domain::CsvSplitSession::SplitSource.new(path: source_path, separator: ",", headers_present: true)
      options = Csvtool::Domain::CsvSplitSession::SplitOptions.new(
        chunk_size: 10,
        output_directory: output_dir,
        file_prefix: "batch"
      )
      session = Csvtool::Domain::CsvSplitSession::SplitSession.start(source: source, options: options)

      result = use_case.call(session: session)

      assert result.ok?
      assert Dir.exist?(output_dir)
      assert File.file?(File.join(output_dir, "batch_part_001.csv"))
    end
  end
end
