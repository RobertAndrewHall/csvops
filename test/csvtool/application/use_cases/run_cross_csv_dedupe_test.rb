# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_cross_csv_dedupe"

class RunCrossCsvDedupeTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_prompts_for_both_files_and_columns
    output = StringIO.new
    input = [
      fixture_path("sample_people.csv"),
      fixture_path("sample_people.csv"),
      "name",
      "name"
    ].join("\n") + "\n"

    Csvtool::Application::UseCases::RunCrossCsvDedupe.new(stdin: StringIO.new(input), stdout: output).call

    assert_includes output.string, "CSV file path:"
    assert_includes output.string, "Reference CSV file path:"
    assert_includes output.string, "Source key column name:"
    assert_includes output.string, "Reference key column name:"
    assert_includes output.string, "Dedupe workflow selected."
  end
end
