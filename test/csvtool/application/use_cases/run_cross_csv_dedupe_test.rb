# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_cross_csv_dedupe"
require "csvtool/domain/cross_csv_dedupe_session/cross_csv_dedupe_session"
require "csvtool/domain/cross_csv_dedupe_session/csv_profile"
require "csvtool/domain/cross_csv_dedupe_session/column_selector"
require "csvtool/domain/cross_csv_dedupe_session/key_mapping"
require "csvtool/domain/cross_csv_dedupe_session/match_options"
require "csvtool/domain/shared/output_destination"
require "tmpdir"

class RunCrossCsvDedupeTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_streams_retained_rows_to_callbacks
    use_case = Csvtool::Application::UseCases::RunCrossCsvDedupe.new
    headers = nil
    rows = []

    result = use_case.call(
      session: build_session(
        source_path: fixture_path("dedupe_source.csv"),
        reference_path: fixture_path("dedupe_reference.csv"),
        source_selector_input: "customer_id",
        reference_selector_input: "external_id",
        output_destination: Csvtool::Domain::Shared::OutputDestination.console
      ),
      on_header: ->(value) { headers = value },
      on_row: ->(fields) { rows << fields }
    )

    assert_equal true, result.ok?
    assert_equal ["customer_id", "name"], headers
    assert_equal [%w[1 Alice], %w[3 Cara]], rows
    assert_equal 5, result.data[:stats][:source_rows]
    assert_equal 3, result.data[:stats][:removed_rows]
    assert_equal 2, result.data[:stats][:kept_rows_count]
  end

  def test_writes_to_file_output_destination
    use_case = Csvtool::Application::UseCases::RunCrossCsvDedupe.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "deduped.csv")
      result = use_case.call(
        session: build_session(
          source_path: fixture_path("dedupe_source.csv"),
          reference_path: fixture_path("dedupe_reference.csv"),
          source_selector_input: "customer_id",
          reference_selector_input: "external_id",
          output_destination: Csvtool::Domain::Shared::OutputDestination.file(path: output_path)
        )
      )

      assert_equal true, result.ok?
      assert_equal output_path, result.data[:output_path]
      assert_equal "customer_id,name\n1,Alice\n3,Cara\n", File.read(output_path)
    end
  end

  def test_returns_column_not_found_when_selector_invalid
    use_case = Csvtool::Application::UseCases::RunCrossCsvDedupe.new

    result = use_case.call(
      session: build_session(
        source_path: fixture_path("dedupe_source.csv"),
        reference_path: fixture_path("dedupe_reference.csv"),
        source_selector_input: "missing",
        reference_selector_input: "external_id",
        output_destination: Csvtool::Domain::Shared::OutputDestination.console
      )
    )

    assert_equal false, result.ok?
    assert_equal :column_not_found, result.error
  end

  private

  def build_session(source_path:, reference_path:, source_selector_input:, reference_selector_input:, output_destination:)
    source = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: source_path,
      separator: ",",
      headers_present: true
    )
    reference = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: reference_path,
      separator: ",",
      headers_present: true
    )
    key_mapping = Csvtool::Domain::CrossCsvDedupeSession::KeyMapping.new(
      source_selector: Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(
        headers_present: true,
        input: source_selector_input
      ),
      reference_selector: Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(
        headers_present: true,
        input: reference_selector_input
      )
    )
    match_options = Csvtool::Domain::CrossCsvDedupeSession::MatchOptions.new(
      trim_whitespace: true,
      case_insensitive: false
    )

    Csvtool::Domain::CrossCsvDedupeSession::CrossCsvDedupeSession
      .start(source: source, reference: reference, key_mapping: key_mapping, match_options: match_options)
      .with_output_destination(output_destination)
  end
end
