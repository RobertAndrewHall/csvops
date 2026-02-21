# frozen_string_literal: true

require_relative "../test_helper"
require "csvtool/cli"
require "tmpdir"

class TestCli < Minitest::Test
  def fixture_path(name)
    File.expand_path("../fixtures/#{name}", __dir__)
  end

  def test_menu_can_exit_cleanly
    output = StringIO.new
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new("2\n"), stdout: output, stderr: StringIO.new)
    assert_equal 0, status
    assert_includes output.string, "CSV Tool Menu"
  end

  def test_end_to_end_console_happy_path_prints_expected_values
    input = [
      "1",
      fixture_path("sample_people.csv"),
      "1",
      "",
      "1",
      "",
      "y",
      "",
      "2"
    ].join("\n") + "\n"

    output = StringIO.new
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_match(/\nAlice\nBob\nCara\n/, output.string)
  end

  def test_end_to_end_file_output_writes_expected_csv
    output = StringIO.new
    output_path = nil

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "names.csv")
      input = [
        "1",
        fixture_path("sample_people.csv"),
        "1",
        "",
        "1",
        "",
        "y",
        "2",
        output_path,
        "2"
      ].join("\n") + "\n"

      status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)
      assert_equal 0, status
      assert_equal "name\nAlice\nBob\nCara\n", File.read(output_path)
    end

    assert_includes output.string, "Wrote output to #{output_path}"
  end

  def test_preview_cancel_returns_to_menu
    input = [
      "1",
      fixture_path("sample_people_many.csv"),
      "1",
      "",
      "1",
      "",
      "n",
      "2"
    ].join("\n") + "\n"

    output = StringIO.new
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Canceled."
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_missing_file_shows_error_and_returns_to_menu
    output = StringIO.new
    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new("1\n/tmp/does-not-exist.csv\n2\n"),
      stdout: output,
      stderr: StringIO.new
    )

    assert_equal 0, status
    assert_includes output.string, "File not found: /tmp/does-not-exist.csv"
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_invalid_output_path_shows_error_and_returns_to_menu
    input = [
      "1",
      fixture_path("sample_people.csv"),
      "1",
      "",
      "1",
      "",
      "y",
      "2",
      "/tmp/not-a-dir/out.csv",
      "2"
    ].join("\n") + "\n"

    output = StringIO.new
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Cannot write output file: /tmp/not-a-dir/out.csv"
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
  end
end
