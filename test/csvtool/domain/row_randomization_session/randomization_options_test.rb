# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_randomization_session/randomization_options"

class RandomizationOptionsTest < Minitest::Test
  def test_accepts_nil_or_integer_seed
    with_seed = Csvtool::Domain::RowRandomizationSession::RandomizationOptions.new(seed: 42)
    without_seed = Csvtool::Domain::RowRandomizationSession::RandomizationOptions.new(seed: nil)

    assert_equal 42, with_seed.seed
    assert_nil without_seed.seed
  end

  def test_rejects_non_integer_seed
    assert_raises(ArgumentError) do
      Csvtool::Domain::RowRandomizationSession::RandomizationOptions.new(seed: "abc")
    end
  end
end
