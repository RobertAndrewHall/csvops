# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_row_extraction"
require "csvtool/domain/row_session/row_source"
require "csvtool/domain/row_session/row_range"
require "csvtool/domain/row_session/row_session"
require "csvtool/domain/shared/output_destination"
require "tmpdir"

class RunRowExtractionTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def build_session(file_path:, separator: ",", start_row:, end_row:, output: :console, output_path: nil)
    source = Csvtool::Domain::RowSession::RowSource.new(path: file_path, separator: separator)
    row_range = Csvtool::Domain::RowSession::RowRange.new(start_row: start_row, end_row: end_row)
    session = Csvtool::Domain::RowSession::RowSession.start(source: source, row_range: row_range)

    session.with_output_destination(
      if output == :file
        Csvtool::Domain::Shared::OutputDestination.file(path: output_path)
      else
        Csvtool::Domain::Shared::OutputDestination.console
      end
    )
  end

  def test_read_headers_returns_headers_for_valid_file
    use_case = Csvtool::Application::UseCases::RunRowExtraction.new

    result = use_case.read_headers(file_path: fixture_path("sample_people.csv"), col_sep: ",")

    assert result.ok?
    assert_equal ["name", "city"], result.data[:headers]
  end

  def test_read_headers_fails_when_file_is_missing
    use_case = Csvtool::Application::UseCases::RunRowExtraction.new

    result = use_case.read_headers(file_path: "/tmp/not-present.csv", col_sep: ",")

    refute result.ok?
    assert_equal :file_not_found, result.error
  end

  def test_extract_streams_rows_for_console_mode
    use_case = Csvtool::Application::UseCases::RunRowExtraction.new
    session = build_session(file_path: fixture_path("sample_people.csv"), start_row: 2, end_row: 3)
    headers = ["name", "city"]
    rows = []

    result = use_case.extract(session: session, headers: headers, on_row: ->(fields) { rows << fields })

    assert result.ok?
    assert_equal true, result.data[:matched]
    assert_equal 3, result.data[:row_count]
    assert_equal [["Bob", "Paris"], ["Cara", "Berlin"]], rows
  end

  def test_extract_writes_rows_to_file_mode
    use_case = Csvtool::Application::UseCases::RunRowExtraction.new
    headers = ["name", "city"]

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "rows.csv")
      session = build_session(
        file_path: fixture_path("sample_people.csv"),
        start_row: 2,
        end_row: 3,
        output: :file,
        output_path: output_path
      )

      result = use_case.extract(session: session, headers: headers)

      assert result.ok?
      assert_equal true, result.data[:wrote_rows]
      assert_equal "name,city\nBob,Paris\nCara,Berlin\n", File.read(output_path)
    end
  end

  def test_extract_reports_out_of_bounds_via_stats
    use_case = Csvtool::Application::UseCases::RunRowExtraction.new
    session = build_session(file_path: fixture_path("sample_people.csv"), start_row: 10, end_row: 12)
    headers = ["name", "city"]

    result = use_case.extract(session: session, headers: headers)

    assert result.ok?
    assert_equal false, result.data[:matched]
    assert_equal 3, result.data[:row_count]
  end
end
