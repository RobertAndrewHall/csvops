# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_row_range_shell"

class RunRowRangeShellTest < Minitest::Test
  def test_use_case_prints_selected_row_range_with_header
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    input = [fixture, "2", "3"].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "name,city"
    assert_includes out.string, "Bob,Paris"
    assert_includes out.string, "Cara,Berlin"
    refute_includes out.string, "Alice,London"
  end
end
