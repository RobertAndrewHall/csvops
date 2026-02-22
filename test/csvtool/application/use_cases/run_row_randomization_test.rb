# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_row_randomization"
require "csvtool/domain/row_randomization_session/randomization_source"
require "csvtool/domain/row_randomization_session/randomization_options"
require "csvtool/domain/row_randomization_session/randomization_session"
require "csvtool/domain/shared/output_destination"
require "tmpdir"

class RunRowRandomizationTest < Minitest::Test
  class RaisingWriter
    def call(**_kwargs)
      raise Errno::ENOENT
    end
  end

  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def build_session(file_path:, separator: ",", headers_present: true, seed: nil, output: :console, output_path: nil)
    source = Csvtool::Domain::RowRandomizationSession::RandomizationSource.new(
      path: file_path,
      separator: separator,
      headers_present: headers_present
    )
    options = Csvtool::Domain::RowRandomizationSession::RandomizationOptions.new(seed: seed)
    session = Csvtool::Domain::RowRandomizationSession::RandomizationSession.start(source: source, options: options)

    session.with_output_destination(
      if output == :file
        Csvtool::Domain::Shared::OutputDestination.file(path: output_path)
      else
        Csvtool::Domain::Shared::OutputDestination.console
      end
    )
  end

  def test_read_headers_returns_headers_when_enabled
    use_case = Csvtool::Application::UseCases::RunRowRandomization.new

    result = use_case.read_headers(file_path: fixture_path("sample_people.csv"), col_sep: ",", headers_present: true)

    assert result.ok?
    assert_equal ["name", "city"], result.data[:headers]
  end

  def test_read_headers_returns_nil_when_headers_disabled
    use_case = Csvtool::Application::UseCases::RunRowRandomization.new

    result = use_case.read_headers(file_path: fixture_path("sample_people_no_headers.csv"), col_sep: ",", headers_present: false)

    assert result.ok?
    assert_nil result.data[:headers]
  end

  def test_read_headers_fails_for_missing_file
    use_case = Csvtool::Application::UseCases::RunRowRandomization.new

    result = use_case.read_headers(file_path: "/tmp/not-present.csv", col_sep: ",", headers_present: true)

    refute result.ok?
    assert_equal :file_not_found, result.error
  end

  def test_randomize_streams_rows_for_console_mode
    use_case = Csvtool::Application::UseCases::RunRowRandomization.new
    session = build_session(file_path: fixture_path("sample_people.csv"), seed: 123)
    rows = []

    result = use_case.randomize(session: session, headers: ["name", "city"], on_row: ->(fields) { rows << fields })

    assert result.ok?
    assert_equal 3, rows.length
    assert_equal [["Alice", "London"], ["Bob", "Paris"], ["Cara", "Berlin"]].sort, rows.sort
  end

  def test_randomize_writes_rows_to_file
    use_case = Csvtool::Application::UseCases::RunRowRandomization.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "randomized.csv")
      session = build_session(
        file_path: fixture_path("sample_people.csv"),
        seed: 123,
        output: :file,
        output_path: output_path
      )

      result = use_case.randomize(session: session, headers: ["name", "city"])

      assert result.ok?
      assert_equal output_path, result.data[:output_path]
      lines = File.read(output_path).lines.map(&:strip)
      assert_equal "name,city", lines.first
      assert_equal ["Alice,London", "Bob,Paris", "Cara,Berlin"].sort, lines[1..].sort
    end
  end

  def test_same_seed_produces_stable_order
    use_case = Csvtool::Application::UseCases::RunRowRandomization.new
    session_1 = build_session(file_path: fixture_path("sample_people_many.csv"), seed: 123)
    session_2 = build_session(file_path: fixture_path("sample_people_many.csv"), seed: 123)
    rows_1 = []
    rows_2 = []

    result_1 = use_case.randomize(session: session_1, headers: ["name", "city"], on_row: ->(fields) { rows_1 << fields })
    result_2 = use_case.randomize(session: session_2, headers: ["name", "city"], on_row: ->(fields) { rows_2 << fields })

    assert result_1.ok?
    assert result_2.ok?
    assert_equal rows_1, rows_2
  end

  def test_randomize_returns_cannot_write_output_file_when_writer_fails
    use_case = Csvtool::Application::UseCases::RunRowRandomization.new(
      csv_randomized_row_file_writer: RaisingWriter.new
    )
    session = build_session(
      file_path: fixture_path("sample_people.csv"),
      seed: 123,
      output: :file,
      output_path: "/tmp/randomized.csv"
    )

    result = use_case.randomize(session: session, headers: ["name", "city"])

    refute result.ok?
    assert_equal :cannot_write_output_file, result.error
    assert_equal "/tmp/randomized.csv", result.data[:path]
    assert_equal Errno::ENOENT, result.data[:error_class]
  end
end
