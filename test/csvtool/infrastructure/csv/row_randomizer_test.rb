# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/csv/row_randomizer"

class InfrastructureRowRandomizerTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_randomizes_rows_and_preserves_membership
    randomizer = Csvtool::Infrastructure::CSV::RowRandomizer.new(rng: Random.new(1234))

    rows = randomizer.call(file_path: fixture_path("sample_people.csv"), col_sep: ",")

    assert_equal 3, rows.length
    assert_equal [%w[Alice London], %w[Bob Paris], %w[Cara Berlin]].sort, rows.sort
  end

  def test_avoids_returning_same_order_for_multi_row_input
    randomizer = Csvtool::Infrastructure::CSV::RowRandomizer.new(rng: Random.new(7))

    rows = randomizer.call(file_path: fixture_path("sample_people.csv"), col_sep: ",")

    refute_equal [%w[Alice London], %w[Bob Paris], %w[Cara Berlin]], rows
  end
end
