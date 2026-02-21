# frozen_string_literal: true

require_relative "test_helper"
require "csvtool/cli"

class TestCli < Minitest::Test
  def fixture_path(name)
    File.expand_path("fixtures/#{name}", __dir__)
  end

  def test_menu_displays_expected_options
    output = StringIO.new
    error = StringIO.new

    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new("2\n"),
      stdout: output,
      stderr: error
    )

    text = output.string
    assert_equal 0, status
    assert_includes text, "CSV Tool Menu"
    assert_includes text, "1. Extract column"
    assert_includes text, "2. Exit"
  end

  def test_menu_contains_only_story_one_options
    output = StringIO.new

    Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new("2\n"),
      stdout: output,
      stderr: StringIO.new
    )

    menu_lines = output.string.lines.select { |line| line.match?(/^\d+\.\s/) }.map(&:strip)
    assert_equal ["1. Extract column", "2. Exit"], menu_lines
  end

  def test_invalid_choice_then_exit_is_safe
    output = StringIO.new
    error = StringIO.new

    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new("x\n2\n"),
      stdout: output,
      stderr: error
    )

    assert_equal 0, status
    assert_includes output.string, "Please choose 1 or 2."
  end

  def test_happy_path_extracts_column_values_one_per_line
    output = StringIO.new
    error = StringIO.new
    input = [
      "1",
      fixture_path("sample_people.csv"),
      "1",
      "",
      "1",
      "",
      "2"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new(input),
      stdout: output,
      stderr: error
    )

    text = output.string
    assert_equal 0, status
    assert_includes text, "CSV file path: "
    assert_includes text, "Choose separator:"
    assert_includes text, "Select column:"
    assert_includes text, "Skip blank values? [Y/n]: "
    assert_includes text, "1. name"
    assert_includes text, "2. city"
    assert_match(/Skip blank values\? \[Y\/n\]: Alice\nBob\nCara\n/, text)
  end

  def test_guided_column_selection_with_filter_prints_selected_column_values
    output = StringIO.new
    error = StringIO.new
    input = [
      "1",
      fixture_path("sample_people.csv"),
      "1",
      "ci",
      "1",
      "",
      "2"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new(input),
      stdout: output,
      stderr: error
    )

    text = output.string
    assert_equal 0, status
    assert_includes text, "Filter columns (optional): "
    assert_includes text, "Select column:"
    assert_includes text, "1. city"
    refute_includes text, "1. name"
    assert_match(/Skip blank values\? \[Y\/n\]: London\nParis\nBerlin\n/, text)
  end

  def test_missing_file_shows_friendly_error_and_returns_to_menu
    output = StringIO.new
    error = StringIO.new
    input = [
      "1",
      "/tmp/does-not-exist.csv",
      "2"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new(input),
      stdout: output,
      stderr: error
    )

    text = output.string
    assert_equal 0, status
    assert_includes text, "File not found: /tmp/does-not-exist.csv"
    assert_operator text.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_empty_csv_shows_no_headers_message_and_returns_to_menu
    output = StringIO.new
    error = StringIO.new
    input = [
      "1",
      fixture_path("empty.csv"),
      "1",
      "2"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new(input),
      stdout: output,
      stderr: error
    )

    text = output.string
    assert_equal 0, status
    assert_includes text, "No headers found."
    assert_operator text.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_invalid_column_selection_shows_column_not_found_and_returns_to_menu
    output = StringIO.new
    error = StringIO.new
    input = [
      "1",
      fixture_path("sample_people.csv"),
      "1",
      "",
      "9",
      "2"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new(input),
      stdout: output,
      stderr: error
    )

    text = output.string
    assert_equal 0, status
    assert_includes text, "Column not found."
    assert_operator text.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_tsv_separator_choice_extracts_values
    output = StringIO.new
    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new(["1", fixture_path("sample_people.tsv"), "2", "", "1", "", "2"].join("\n") + "\n"),
      stdout: output,
      stderr: StringIO.new
    )

    text = output.string
    assert_equal 0, status
    assert_includes text, "2. tab (\\t)"
    assert_match(/Skip blank values\? \[Y\/n\]: Alice\nBob\nCara\n/, text)
  end

  def test_custom_separator_choice_extracts_values
    output = StringIO.new
    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new(["1", fixture_path("sample_people_colon.txt"), "5", ":", "", "1", "", "2"].join("\n") + "\n"),
      stdout: output,
      stderr: StringIO.new
    )

    text = output.string
    assert_equal 0, status
    assert_includes text, "Custom separator: "
    assert_match(/Skip blank values\? \[Y\/n\]: Alice\nBob\nCara\n/, text)
  end

  def test_skip_blanks_default_on_excludes_blank_and_whitespace_values
    output = StringIO.new
    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new(["1", fixture_path("sample_people_blanks.csv"), "1", "", "1", "", "2"].join("\n") + "\n"),
      stdout: output,
      stderr: StringIO.new
    )

    text = output.string
    assert_equal 0, status
    assert_match(/Skip blank values\? \[Y\/n\]: Alice\nBob\nCara\n/, text)
    refute_match(/\n \n/, text)
  end

  def test_skip_blanks_can_be_disabled_with_no
    output = StringIO.new
    status = Csvtool::CLI.start(
      ["menu"],
      stdin: StringIO.new(["1", fixture_path("sample_people_blanks.csv"), "1", "", "1", "n", "2"].join("\n") + "\n"),
      stdout: output,
      stderr: StringIO.new
    )

    text = output.string
    assert_equal 0, status
    assert_match(/Skip blank values\? \[Y\/n\]: Alice\n \n\nBob\nCara\n/, text)
  end
end
