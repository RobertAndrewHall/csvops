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
      source_column: "customer_id",
      reference_column: "external_id",
      col_sep: ","
    )

    assert_equal ["customer_id", "name"], result[:headers]
    assert_equal 5, result[:source_rows]
    assert_equal 3, result[:removed_rows]
    assert_equal 2, result[:kept_rows_count]
    assert_equal [%w[1 Alice], %w[3 Cara]], result[:kept_rows]
  end
end
