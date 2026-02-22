# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/cross_csv_dedupe_session/match_options"

class CrossCsvDedupeMatchOptionsTest < Minitest::Test
  def test_predicates_return_boolean_flags
    options = Csvtool::Domain::CrossCsvDedupeSession::MatchOptions.new(
      trim_whitespace: true,
      case_insensitive: false
    )

    assert_equal true, options.trim_whitespace?
    assert_equal false, options.case_insensitive?
  end
end
