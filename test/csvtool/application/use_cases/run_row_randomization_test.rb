# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_row_randomization"

class RunRowRandomizationTest < Minitest::Test
  def test_prompts_for_file_and_returns_to_menu_without_error
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    output = StringIO.new
    input = StringIO.new("#{fixture}\n")

    Csvtool::Application::UseCases::RunRowRandomization.new(stdin: input, stdout: output).call

    assert_includes output.string, "CSV file path:"
    assert_includes output.string, "Randomize rows workflow selected for: #{fixture}"
  end
end
