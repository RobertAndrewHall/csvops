# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/csv/cross_csv_deduper"
require "tmpdir"

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

  def test_each_retained_streams_rows_and_reports_stats
    deduper = Csvtool::Infrastructure::CSV::CrossCsvDeduper.new
    yielded_rows = []

    result = deduper.each_retained(
      source_path: fixture_path("dedupe_source.csv"),
      reference_path: fixture_path("dedupe_reference.csv"),
      source_selector: "customer_id",
      reference_selector: "external_id"
    ) { |fields| yielded_rows << fields }

    assert_equal [%w[1 Alice], %w[3 Cara]], yielded_rows
    assert_equal 5, result[:source_rows]
    assert_equal 3, result[:removed_rows]
    assert_equal 2, result[:kept_rows_count]
    refute_includes result.keys, :kept_rows
  end

  def test_each_retained_supports_large_inputs_with_streaming
    deduper = Csvtool::Infrastructure::CSV::CrossCsvDeduper.new

    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "source.csv")
      reference_path = File.join(dir, "reference.csv")

      File.open(source_path, "w") do |file|
        file.puts "id,name"
        10_000.times { |index| file.puts "#{index},name#{index}" }
      end

      File.open(reference_path, "w") do |file|
        file.puts "external_id"
        10_000.times do |index|
          file.puts index.to_s if (index % 2).zero?
        end
      end

      yielded_count = 0
      result = deduper.each_retained(
        source_path: source_path,
        reference_path: reference_path,
        source_selector: "id",
        reference_selector: "external_id"
      ) { |_fields| yielded_count += 1 }

      assert_equal 10_000, result[:source_rows]
      assert_equal 5_000, result[:removed_rows]
      assert_equal 5_000, result[:kept_rows_count]
      assert_equal 5_000, yielded_count
    end
  end
end
