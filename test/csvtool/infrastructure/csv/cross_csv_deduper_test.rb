# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/csv/cross_csv_deduper"

class InfrastructureCrossCsvDeduperTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_filters_source_rows_by_reference_column_values
    deduper = Csvtool::Infrastructure::CSV::CrossCsvDeduper.new

    result = deduper.call(
      source_path: fixture_path("dedupe_source.csv"),
      reference_path: fixture_path("dedupe_reference.csv"),
      source_selector: "customer_id",
      reference_selector: "external_id",
      source_col_sep: ",",
      reference_col_sep: ",",
      source_has_headers: true,
      reference_has_headers: true
    )

    assert_equal ["customer_id", "name"], result[:headers]
    assert_equal 5, result[:source_rows]
    assert_equal 3, result[:removed_rows]
    assert_equal 2, result[:kept_rows_count]
    assert_equal [%w[1 Alice], %w[3 Cara]], result[:kept_rows]
  end

  def test_normalization_trim_on_case_off
    deduper = Csvtool::Infrastructure::CSV::CrossCsvDeduper.new

    result = deduper.call(
      source_path: fixture_path("dedupe_source_normalization.csv"),
      reference_path: fixture_path("dedupe_reference_normalization.csv"),
      source_selector: "customer_id",
      reference_selector: "external_id",
      trim_whitespace: true,
      case_insensitive: false
    )

    assert_equal 3, result[:kept_rows_count]
  end

  def test_normalization_trim_on_case_on
    deduper = Csvtool::Infrastructure::CSV::CrossCsvDeduper.new

    result = deduper.call(
      source_path: fixture_path("dedupe_source_normalization.csv"),
      reference_path: fixture_path("dedupe_reference_normalization.csv"),
      source_selector: "customer_id",
      reference_selector: "external_id",
      trim_whitespace: true,
      case_insensitive: true
    )

    assert_equal 1, result[:kept_rows_count]
    assert_equal [%w[B2 Bob]], result[:kept_rows]
  end

  def test_normalization_trim_off_case_on
    deduper = Csvtool::Infrastructure::CSV::CrossCsvDeduper.new

    result = deduper.call(
      source_path: fixture_path("dedupe_source_normalization.csv"),
      reference_path: fixture_path("dedupe_reference_normalization.csv"),
      source_selector: "customer_id",
      reference_selector: "external_id",
      trim_whitespace: false,
      case_insensitive: true
    )

    assert_equal 2, result[:kept_rows_count]
    assert_equal [[" A1 ", "Alice"], %w[B2 Bob]], result[:kept_rows]
  end

  def test_normalization_trim_off_case_off
    deduper = Csvtool::Infrastructure::CSV::CrossCsvDeduper.new

    result = deduper.call(
      source_path: fixture_path("dedupe_source_normalization.csv"),
      reference_path: fixture_path("dedupe_reference_normalization.csv"),
      source_selector: "customer_id",
      reference_selector: "external_id",
      trim_whitespace: false,
      case_insensitive: false
    )

    assert_equal 3, result[:kept_rows_count]
  end
end
