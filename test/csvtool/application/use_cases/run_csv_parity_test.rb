# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_csv_parity"
require "csvtool/domain/csv_parity_session/source_pair"
require "csvtool/domain/csv_parity_session/parity_options"
require "csvtool/domain/csv_parity_session/parity_session"

class RunCsvParityTest < Minitest::Test
  class EaccesComparator
    def call(left_path:, right_path:, col_sep:, headers_present:, sample_limit: 5)
      error = Errno::EACCES.new("/tmp/protected.csv")
      def error.path
        "/tmp/protected.csv"
      end
      raise error
    end
  end

  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def build_session(left_path:, right_path:, separator: ",", headers_present: true)
    source_pair = Csvtool::Domain::CsvParitySession::SourcePair.new(
      left_path: left_path,
      right_path: right_path
    )
    options = Csvtool::Domain::CsvParitySession::ParityOptions.new(
      separator: separator,
      headers_present: headers_present
    )
    Csvtool::Domain::CsvParitySession::ParitySession.start(
      source_pair: source_pair,
      options: options
    )
  end

  def test_returns_match_for_equivalent_files
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      session: build_session(
        left_path: fixture_path("sample_people.csv"),
        right_path: fixture_path("parity_people_reordered.csv")
      )
    )

    assert_equal true, result.ok?
    assert_equal true, result.data[:match]
    assert_equal 0, result.data[:left_only_count]
    assert_equal 0, result.data[:right_only_count]
  end

  def test_returns_mismatch_counts_for_non_equivalent_files
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      session: build_session(
        left_path: fixture_path("sample_people.csv"),
        right_path: fixture_path("parity_people_mismatch.csv")
      )
    )

    assert_equal true, result.ok?
    assert_equal false, result.data[:match]
    assert_equal 1, result.data[:left_only_count]
    assert_equal 1, result.data[:right_only_count]
  end

  def test_duplicate_count_differences_are_detected
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      session: build_session(
        left_path: fixture_path("parity_duplicates_left.csv"),
        right_path: fixture_path("parity_duplicates_right.csv")
      )
    )

    assert_equal true, result.ok?
    assert_equal false, result.data[:match]
    assert_equal 1, result.data[:left_only_count]
    assert_equal 0, result.data[:right_only_count]
    assert_equal "1,Alice", result.data[:left_only_examples][0][:row]
    assert_equal 1, result.data[:left_only_examples][0][:count_delta]
  end

  def test_headered_mode_fails_when_headers_do_not_match
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      session: build_session(
        left_path: fixture_path("sample_people.csv"),
        right_path: fixture_path("parity_people_header_mismatch.csv")
      )
    )

    assert_equal false, result.ok?
    assert_equal :header_mismatch, result.error
  end

  def test_headerless_mode_compares_all_rows_as_data
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      session: build_session(
        left_path: fixture_path("sample_people_no_headers.csv"),
        right_path: fixture_path("sample_people_no_headers.csv"),
        headers_present: false
      )
    )

    assert_equal true, result.ok?
    assert_equal true, result.data[:match]
  end

  def test_returns_file_not_found_for_left_side
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      session: build_session(
        left_path: "/tmp/nope-left.csv",
        right_path: fixture_path("sample_people.csv")
      )
    )

    assert_equal false, result.ok?
    assert_equal :file_not_found, result.error
    assert_equal "/tmp/nope-left.csv", result.data[:path]
  end

  def test_returns_file_not_found_for_right_side
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      session: build_session(
        left_path: fixture_path("sample_people.csv"),
        right_path: "/tmp/nope-right.csv"
      )
    )

    assert_equal false, result.ok?
    assert_equal :file_not_found, result.error
    assert_equal "/tmp/nope-right.csv", result.data[:path]
  end

  def test_returns_parse_error_for_malformed_csv
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      session: build_session(
        left_path: fixture_path("sample_people.csv"),
        right_path: fixture_path("sample_people_bad_tail.csv")
      )
    )

    assert_equal false, result.ok?
    assert_equal :could_not_parse_csv, result.error
  end

  def test_returns_cannot_read_file_when_eacces_is_raised
    result = Csvtool::Application::UseCases::RunCsvParity.new(
      comparator: EaccesComparator.new
    ).call(
      session: build_session(
        left_path: fixture_path("sample_people.csv"),
        right_path: fixture_path("sample_people.csv")
      )
    )

    assert_equal false, result.ok?
    assert_equal :cannot_read_file, result.error
    assert_equal "/tmp/protected.csv", result.data[:path]
  end
end
