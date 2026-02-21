# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_extraction"

class RunExtractionTest < Minitest::Test
  def test_missing_file_path_reports_error
    out = StringIO.new
    use_case = Csvtool::Application::UseCases::RunExtraction.new(
      stdin: StringIO.new("/tmp/not-present.csv\n"),
      stdout: out
    )

    use_case.call

    assert_includes out.string, "File not found: /tmp/not-present.csv"
  end

  def test_use_case_can_run_console_happy_path
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    input = ["#{fixture}", "1", "", "1", "", "y", ""].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunExtraction.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "Alice"
    assert_includes out.string, "Bob"
    assert_includes out.string, "Cara"
  end
end
