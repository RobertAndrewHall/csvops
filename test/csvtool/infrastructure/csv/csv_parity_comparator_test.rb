# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/csv/csv_parity_comparator"

class CsvParityComparatorTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_reports_match_when_rows_are_equal_ignoring_order
    comparator = Csvtool::Infrastructure::CSV::CsvParityComparator.new

    result = comparator.call(
      left_path: fixture_path("sample_people.csv"),
      right_path: fixture_path("parity_people_reordered.csv"),
      col_sep: ",",
      headers_present: true
    )

    assert_equal true, result[:match]
    assert_equal 0, result[:left_only_count]
    assert_equal 0, result[:right_only_count]
  end

  def test_reports_mismatch_counts_for_different_rows
    comparator = Csvtool::Infrastructure::CSV::CsvParityComparator.new

    result = comparator.call(
      left_path: fixture_path("sample_people.csv"),
      right_path: fixture_path("parity_people_mismatch.csv"),
      col_sep: ",",
      headers_present: true
    )

    assert_equal false, result[:match]
    assert_equal 1, result[:left_only_count]
    assert_equal 1, result[:right_only_count]
    assert_equal "Cara,Berlin", result[:left_only_examples][0][:row]
    assert_equal 1, result[:left_only_examples][0][:count_delta]
    assert_equal "Dina,Rome", result[:right_only_examples][0][:row]
    assert_equal 1, result[:right_only_examples][0][:count_delta]
  end

  def test_respects_duplicate_counts
    comparator = Csvtool::Infrastructure::CSV::CsvParityComparator.new

    result = comparator.call(
      left_path: fixture_path("parity_duplicates_left.csv"),
      right_path: fixture_path("parity_duplicates_right.csv"),
      col_sep: ",",
      headers_present: true
    )

    assert_equal false, result[:match]
    assert_equal 1, result[:left_only_count]
    assert_equal 0, result[:right_only_count]
    assert_equal "1,Alice", result[:left_only_examples][0][:row]
    assert_equal 1, result[:left_only_examples][0][:count_delta]
  end
end
