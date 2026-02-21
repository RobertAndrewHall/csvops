# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_row_randomization"
require "tmpdir"

class RunRowRandomizationTest < Minitest::Test
  def test_prints_header_then_all_randomized_rows
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    output = StringIO.new
    input = StringIO.new("#{fixture}\n\n")

    Csvtool::Application::UseCases::RunRowRandomization.new(stdin: input, stdout: output).call

    assert_includes output.string, "CSV file path:"
    csv_lines = output.string.lines.map(&:strip).select { |line| line.include?(",") && !line.start_with?("CSV file path:") }
    assert_equal "name,city", csv_lines.first
    assert_equal ["Alice,London", "Bob,Paris", "Cara,Berlin"].sort, csv_lines[1..].sort
  end

  def test_missing_file_shows_friendly_error
    output = StringIO.new
    input = StringIO.new("/tmp/does-not-exist.csv\n")

    Csvtool::Application::UseCases::RunRowRandomization.new(stdin: input, stdout: output).call

    assert_includes output.string, "File not found: /tmp/does-not-exist.csv"
  end

  def test_can_write_randomized_rows_to_file
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    output = StringIO.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "randomized.csv")
      input = StringIO.new("#{fixture}\n2\n#{output_path}\n")

      Csvtool::Application::UseCases::RunRowRandomization.new(stdin: input, stdout: output).call

      written = File.read(output_path).lines.map(&:strip)
      assert_equal "name,city", written.first
      assert_equal ["Alice,London", "Bob,Paris", "Cara,Berlin"].sort, written[1..].sort
      assert_includes output.string, "Wrote output to #{output_path}"
    end
  end
end
