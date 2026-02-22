# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_extraction"
require "csvtool/domain/column_session/column_session"
require "csvtool/domain/column_session/csv_source"
require "csvtool/domain/column_session/separator"
require "csvtool/domain/column_session/column_selection"
require "csvtool/domain/column_session/extraction_options"
require "csvtool/domain/shared/output_destination"
require "tmpdir"

class RunExtractionTest < Minitest::Test
  class RaisingWriter
    def call(**_kwargs)
      raise Errno::ENOENT
    end
  end

  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_read_headers_missing_file_returns_failure
    result = Csvtool::Application::UseCases::RunExtraction.new.read_headers(
      file_path: "/tmp/not-present.csv",
      col_sep: ","
    )

    assert_equal false, result.ok?
    assert_equal :file_not_found, result.error
  end

  def test_preview_returns_expected_values
    use_case = Csvtool::Application::UseCases::RunExtraction.new

    result = use_case.preview(
      session: build_session(output_destination: Csvtool::Domain::Shared::OutputDestination.console)
    )

    assert_equal true, result.ok?
    assert_equal %w[Alice Bob Cara], result.data[:preview_values]
  end

  def test_extract_writes_values_to_file
    use_case = Csvtool::Application::UseCases::RunExtraction.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "names.csv")
      result = use_case.extract(
        session: build_session(output_destination: Csvtool::Domain::Shared::OutputDestination.file(path: output_path))
      )

      assert_equal true, result.ok?
      assert_equal output_path, result.data[:output_path]
      assert_equal "name\nAlice\nBob\nCara\n", File.read(output_path)
    end
  end

  def test_extract_returns_cannot_write_output_file_when_writer_fails
    use_case = Csvtool::Application::UseCases::RunExtraction.new(csv_file_writer: RaisingWriter.new)

    result = use_case.extract(
      session: build_session(output_destination: Csvtool::Domain::Shared::OutputDestination.file(path: "/tmp/names.csv"))
    )

    assert_equal false, result.ok?
    assert_equal :cannot_write_output_file, result.error
    assert_equal "/tmp/names.csv", result.data[:path]
    assert_equal Errno::ENOENT, result.data[:error_class]
  end

  private

  def build_session(output_destination:)
    session = Csvtool::Domain::ColumnSession::ColumnSession.start(
      source: Csvtool::Domain::ColumnSession::CsvSource.new(
        path: fixture_path("sample_people.csv"),
        separator: Csvtool::Domain::ColumnSession::Separator.new(",")
      ),
      column_selection: Csvtool::Domain::ColumnSession::ColumnSelection.new(name: "name"),
      options: Csvtool::Domain::ColumnSession::ExtractionOptions.new(skip_blanks: true, preview_limit: 10)
    )

    session.with_output_destination(output_destination)
  end
end
