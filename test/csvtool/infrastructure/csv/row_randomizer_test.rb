# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/csv/row_randomizer"

class InfrastructureRowRandomizerTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_randomizes_rows_and_preserves_membership
    randomizer = Csvtool::Infrastructure::CSV::RowRandomizer.new

    rows = randomizer.call(file_path: fixture_path("sample_people.csv"), col_sep: ",", headers: true, seed: 1234)

    assert_equal 3, rows.length
    assert_equal [%w[Alice London], %w[Bob Paris], %w[Cara Berlin]].sort, rows.sort
  end

  def test_avoids_returning_same_order_for_multi_row_input
    randomizer = Csvtool::Infrastructure::CSV::RowRandomizer.new

    rows = randomizer.call(file_path: fixture_path("sample_people.csv"), col_sep: ",", headers: true, seed: 7)

    refute_equal [%w[Alice London], %w[Bob Paris], %w[Cara Berlin]], rows
  end

  def test_same_seed_returns_same_order
    randomizer = Csvtool::Infrastructure::CSV::RowRandomizer.new

    one = randomizer.call(file_path: fixture_path("sample_people_many.csv"), col_sep: ",", headers: true, seed: 42)
    two = randomizer.call(file_path: fixture_path("sample_people_many.csv"), col_sep: ",", headers: true, seed: 42)

    assert_equal one, two
  end

  def test_different_seed_changes_order
    randomizer = Csvtool::Infrastructure::CSV::RowRandomizer.new

    one = randomizer.call(file_path: fixture_path("sample_people_many.csv"), col_sep: ",", headers: true, seed: 42)
    two = randomizer.call(file_path: fixture_path("sample_people_many.csv"), col_sep: ",", headers: true, seed: 43)

    refute_equal one, two
  end
end
