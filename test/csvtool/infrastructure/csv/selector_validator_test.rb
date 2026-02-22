# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/csv/selector_validator"
require "csvtool/domain/cross_csv_dedupe_session/csv_profile"
require "csvtool/domain/cross_csv_dedupe_session/column_selector"

class InfrastructureSelectorValidatorTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_accepts_header_selector_when_column_exists
    validator = Csvtool::Infrastructure::CSV::SelectorValidator.new
    profile = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: fixture_path("dedupe_source.csv"),
      separator: ",",
      headers_present: true
    )
    selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(
      headers_present: true,
      input: "customer_id"
    )

    assert_equal true, validator.valid?(profile: profile, selector: selector)
  end

  def test_rejects_header_selector_when_column_missing
    validator = Csvtool::Infrastructure::CSV::SelectorValidator.new
    profile = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: fixture_path("dedupe_source.csv"),
      separator: ",",
      headers_present: true
    )
    selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(
      headers_present: true,
      input: "missing"
    )

    assert_equal false, validator.valid?(profile: profile, selector: selector)
  end

  def test_accepts_index_selector_when_in_range
    validator = Csvtool::Infrastructure::CSV::SelectorValidator.new
    profile = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: fixture_path("dedupe_source_no_headers.csv"),
      separator: ",",
      headers_present: false
    )
    selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(
      headers_present: false,
      input: "2"
    )

    assert_equal true, validator.valid?(profile: profile, selector: selector)
  end

  def test_rejects_index_selector_when_out_of_range
    validator = Csvtool::Infrastructure::CSV::SelectorValidator.new
    profile = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: fixture_path("dedupe_source_no_headers.csv"),
      separator: ",",
      headers_present: false
    )
    selector = Csvtool::Domain::CrossCsvDedupeSession::ColumnSelector.from_input(
      headers_present: false,
      input: "9"
    )

    assert_equal false, validator.valid?(profile: profile, selector: selector)
  end
end
