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

  def test_normalize_trim_on_case_off
    options = Csvtool::Domain::CrossCsvDedupeSession::MatchOptions.new(
      trim_whitespace: true,
      case_insensitive: false
    )

    assert_equal "AbC", options.normalize(" AbC ")
  end

  def test_normalize_trim_on_case_on
    options = Csvtool::Domain::CrossCsvDedupeSession::MatchOptions.new(
      trim_whitespace: true,
      case_insensitive: true
    )

    assert_equal "abc", options.normalize(" AbC ")
  end

  def test_normalize_trim_off_case_on
    options = Csvtool::Domain::CrossCsvDedupeSession::MatchOptions.new(
      trim_whitespace: false,
      case_insensitive: true
    )

    assert_equal " abc ", options.normalize(" AbC ")
  end

  def test_normalize_trim_off_case_off
    options = Csvtool::Domain::CrossCsvDedupeSession::MatchOptions.new(
      trim_whitespace: false,
      case_insensitive: false
    )

    assert_equal " AbC ", options.normalize(" AbC ")
  end
end
