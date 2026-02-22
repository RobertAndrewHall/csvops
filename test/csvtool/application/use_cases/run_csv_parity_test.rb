# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_csv_parity"

class RunCsvParityTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_returns_match_for_equivalent_files
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      left_path: fixture_path("sample_people.csv"),
      right_path: fixture_path("parity_people_reordered.csv")
    )

    assert_equal true, result.ok?
    assert_equal true, result.data[:match]
    assert_equal 0, result.data[:left_only_count]
    assert_equal 0, result.data[:right_only_count]
  end

  def test_returns_mismatch_counts_for_non_equivalent_files
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      left_path: fixture_path("sample_people.csv"),
      right_path: fixture_path("parity_people_mismatch.csv")
    )

    assert_equal true, result.ok?
    assert_equal false, result.data[:match]
    assert_equal 1, result.data[:left_only_count]
    assert_equal 1, result.data[:right_only_count]
  end

  def test_duplicate_count_differences_are_detected
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      left_path: fixture_path("parity_duplicates_left.csv"),
      right_path: fixture_path("parity_duplicates_right.csv")
    )

    assert_equal true, result.ok?
    assert_equal false, result.data[:match]
    assert_equal 1, result.data[:left_only_count]
    assert_equal 0, result.data[:right_only_count]
  end
end
