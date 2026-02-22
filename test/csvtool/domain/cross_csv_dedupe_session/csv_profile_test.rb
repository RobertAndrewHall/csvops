# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/cross_csv_dedupe_session/csv_profile"

class CrossCsvDedupeCsvProfileTest < Minitest::Test
  def test_initializes_with_expected_fields
    profile = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(
      path: "/tmp/source.csv",
      separator: ",",
      headers_present: true
    )

    assert_equal "/tmp/source.csv", profile.path
    assert_equal ",", profile.separator
    assert_equal true, profile.headers_present?
  end

  def test_requires_path
    error = assert_raises(ArgumentError) do
      Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(path: "", separator: ",", headers_present: true)
    end

    assert_equal "path cannot be empty", error.message
  end
end
