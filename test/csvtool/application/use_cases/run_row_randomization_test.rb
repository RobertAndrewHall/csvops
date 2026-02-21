# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_row_randomization"
require "tmpdir"

class RunRowRandomizationTest < Minitest::Test
  def test_prints_header_then_all_randomized_rows
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    output = StringIO.new
    input = StringIO.new("#{fixture}\n\n\n\n")

    Csvtool::Application::UseCases::RunRowRandomization.new(stdin: input, stdout: output).call

    assert_includes output.string, "CSV file path:"
    header_index = output.string.index("name,city")
    assert header_index
    %w[Alice,London Bob,Paris Cara,Berlin].each do |row|
      row_index = output.string.index(row)
      assert row_index
      assert_operator header_index, :<, row_index
    end
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
      input = StringIO.new("#{fixture}\n\n\n2\n#{output_path}\n")

      Csvtool::Application::UseCases::RunRowRandomization.new(stdin: input, stdout: output).call

      written = File.read(output_path).lines.map(&:strip)
      assert_equal "name,city", written.first
      assert_equal ["Alice,London", "Bob,Paris", "Cara,Berlin"].sort, written[1..].sort
      assert_includes output.string, "Wrote output to #{output_path}"
    end
  end

  def test_supports_tsv_separator
    fixture = File.expand_path("../../../fixtures/sample_people.tsv", __dir__)
    output = StringIO.new
    input = StringIO.new("#{fixture}\n2\n\n\n")

    Csvtool::Application::UseCases::RunRowRandomization.new(stdin: input, stdout: output).call

    assert_includes output.string, "name\tcity"
    assert_includes output.string, "Alice\tLondon"
    assert_includes output.string, "Bob\tParis"
    assert_includes output.string, "Cara\tBerlin"
  end

  def test_supports_custom_separator
    fixture = File.expand_path("../../../fixtures/sample_people_colon.txt", __dir__)
    output = StringIO.new
    input = StringIO.new("#{fixture}\n5\n:\n\n\n")

    Csvtool::Application::UseCases::RunRowRandomization.new(stdin: input, stdout: output).call

    assert_includes output.string, "name:city"
    assert_includes output.string, "Alice:London"
    assert_includes output.string, "Bob:Paris"
    assert_includes output.string, "Cara:Berlin"
  end

  def test_headerless_mode_randomizes_all_rows
    fixture = File.expand_path("../../../fixtures/sample_people_no_headers.csv", __dir__)
    output = StringIO.new
    input = StringIO.new("#{fixture}\n\nn\n\n")

    Csvtool::Application::UseCases::RunRowRandomization.new(stdin: input, stdout: output).call

    refute_includes output.string, "name,city"
    assert_includes output.string, "Alice,London"
    assert_includes output.string, "Bob,Paris"
    assert_includes output.string, "Cara,Berlin"
  end
end
