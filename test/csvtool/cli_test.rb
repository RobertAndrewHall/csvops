# frozen_string_literal: true

require_relative "../test_helper"
require "csvtool/cli"
require "tmpdir"
require "fileutils"

class TestCli < Minitest::Test
  def fixture_path(name)
    File.expand_path("../fixtures/#{name}", __dir__)
  end

  def test_menu_can_exit_cleanly
    output = StringIO.new
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new("8\n"), stdout: output, stderr: StringIO.new)
    assert_equal 0, status
    assert_includes output.string, "CSV Tool Menu"
  end

  def test_stats_workflow_shell_can_run_and_return_to_menu
    output = StringIO.new
    input = [
      "7",
      fixture_path("sample_people.csv"),
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Stats workflow ready."
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_split_workflow_splits_csv_in_menu_flow
    output = StringIO.new
    Dir.mktmpdir do |dir|
      source_path = File.join(dir, "people.csv")
      FileUtils.cp(fixture_path("split_people_25.csv"), source_path)
      input = [
        "6",
        source_path,
        "",
        "",
        "10",
        "",
        "",
        "",
        "",
        "8"
      ].join("\n") + "\n"

      status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

      assert_equal 0, status
      assert_includes output.string, "Chunks written: 3"
      assert File.file?(File.join(dir, "people_part_001.csv"))
      assert File.file?(File.join(dir, "people_part_002.csv"))
      assert File.file?(File.join(dir, "people_part_003.csv"))
    end
  end

  def test_split_workflow_invalid_chunk_size_returns_to_menu
    output = StringIO.new
    input = [
      "6",
      fixture_path("sample_people.csv"),
      "",
      "",
      "0",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Chunk size must be a positive integer."
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
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
      "8"
    ].join("\n") + "\n"

    output = StringIO.new
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_match(/\nAlice\nBob\nCara\n/, output.string)
  end

  def test_column_command_prints_expected_values
    output = StringIO.new
    status = Csvtool::CLI.start(
      ["column", fixture_path("sample_people.csv"), "name"],
      stdin: StringIO.new,
      stdout: output,
      stderr: StringIO.new
    )

    assert_equal 0, status
    assert_equal "Alice\nBob\nCara\n", output.string
  end

  def test_row_range_workflow_prints_selected_rows
    output = StringIO.new
    input = [
      "2",
      fixture_path("sample_people.csv"),
      "",
      "2",
      "3",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "name,city"
    assert_includes output.string, "Bob,Paris"
    assert_includes output.string, "Cara,Berlin"
    refute_includes output.string, "Alice,London"
  end

  def test_row_range_invalid_inputs_return_to_menu
    output = StringIO.new
    input = [
      "2",
      fixture_path("sample_people.csv"),
      "",
      "0",
      "3",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Start row must be a positive integer."
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_row_range_workflow_supports_tsv_separator
    output = StringIO.new
    input = [
      "2",
      fixture_path("sample_people.tsv"),
      "2",
      "2",
      "3",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "name,city"
    assert_includes output.string, "Bob,Paris"
    assert_includes output.string, "Cara,Berlin"
  end

  def test_row_range_workflow_supports_custom_separator
    output = StringIO.new
    input = [
      "2",
      fixture_path("sample_people_colon.txt"),
      "5",
      ":",
      "2",
      "3",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "name,city"
    assert_includes output.string, "Bob,Paris"
    assert_includes output.string, "Cara,Berlin"
  end

  def test_row_range_workflow_can_write_selected_rows_to_file
    output = StringIO.new
    output_path = nil

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "row_range.csv")
      input = [
        "2",
        fixture_path("sample_people.csv"),
        "",
        "2",
        "3",
        "2",
        output_path,
        "8"
      ].join("\n") + "\n"

      status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)
      assert_equal 0, status
      assert_equal "name,city\nBob,Paris\nCara,Berlin\n", File.read(output_path)
    end

    assert_includes output.string, "Wrote output to #{output_path}"
  end

  def test_row_range_workflow_stops_before_malformed_tail
    output = StringIO.new
    input = [
      "2",
      fixture_path("sample_people_bad_tail.csv"),
      "",
      "1",
      "2",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Alice,London"
    assert_includes output.string, "Bob,Paris"
    refute_includes output.string, "Could not parse CSV file."
  end

  def test_randomize_rows_workflow_prints_header_and_all_data_rows
    output = StringIO.new
    input = [
      "3",
      fixture_path("sample_people.csv"),
      "",
      "",
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "name,city"
    assert_includes output.string, "Alice,London"
    assert_includes output.string, "Bob,Paris"
    assert_includes output.string, "Cara,Berlin"
  end

  def test_randomize_rows_workflow_can_write_to_file
    output = StringIO.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "randomized_rows.csv")
      input = [
        "3",
        fixture_path("sample_people.csv"),
        "",
        "",
        "",
        "2",
        output_path,
        "8"
      ].join("\n") + "\n"

      status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

      assert_equal 0, status
      assert_includes output.string, "Wrote output to #{output_path}"
      lines = File.read(output_path).lines.map(&:strip)
      assert_equal "name,city", lines.first
      assert_equal ["Alice,London", "Bob,Paris", "Cara,Berlin"].sort, lines[1..].sort
    end
  end

  def test_randomize_rows_workflow_supports_tsv_separator
    output = StringIO.new
    input = [
      "3",
      fixture_path("sample_people.tsv"),
      "2",
      "",
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "name\tcity"
    assert_includes output.string, "Alice\tLondon"
  end

  def test_randomize_rows_workflow_headerless_mode_randomizes_all_rows
    output = StringIO.new
    input = [
      "3",
      fixture_path("sample_people_no_headers.csv"),
      "",
      "n",
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    refute_includes output.string, "name,city"
    assert_includes output.string, "Alice,London"
    assert_includes output.string, "Bob,Paris"
    assert_includes output.string, "Cara,Berlin"
  end

  def test_randomize_rows_invalid_seed_returns_to_menu
    output = StringIO.new
    input = [
      "3",
      fixture_path("sample_people.csv"),
      "",
      "",
      "abc",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Seed must be an integer."
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_dedupe_workflow_shell_prompts_and_returns_to_menu
    output = StringIO.new
    input = [
      "4",
      fixture_path("dedupe_source.csv"),
      "",
      "",
      fixture_path("dedupe_reference.csv"),
      "",
      "",
      "customer_id",
      "external_id",
      "",
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Reference CSV file path:"
    assert_includes output.string, "Source key column name:"
    assert_includes output.string, "Reference key column name:"
    assert_includes output.string, "customer_id,name"
    assert_includes output.string, "1,Alice"
    assert_includes output.string, "3,Cara"
    assert_includes output.string, "Summary: source_rows=5 removed_rows=3 kept_rows=2"
  end

  def test_dedupe_workflow_can_write_to_file
    output = StringIO.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "deduped.csv")
      input = [
        "4",
        fixture_path("dedupe_source.csv"),
        "",
        "",
        fixture_path("dedupe_reference.csv"),
        "",
        "",
      "customer_id",
      "external_id",
      "",
      "",
      "2",
      output_path,
      "8"
      ].join("\n") + "\n"

      status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

      assert_equal 0, status
      assert_includes output.string, "Wrote output to #{output_path}"
      assert_equal "customer_id,name\n1,Alice\n3,Cara\n", File.read(output_path)
      assert_includes output.string, "Summary: source_rows=5 removed_rows=3 kept_rows=2"
    end
  end

  def test_dedupe_workflow_supports_tsv_separators
    output = StringIO.new
    input = [
      "4",
      fixture_path("dedupe_source.tsv"),
      "2",
      "",
      fixture_path("dedupe_reference.tsv"),
      "2",
      "",
      "customer_id",
      "external_id",
      "",
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "customer_id\tname"
    assert_includes output.string, "1\tAlice"
    assert_includes output.string, "3\tCara"
  end

  def test_dedupe_workflow_headerless_mode_supports_index
    output = StringIO.new
    input = [
      "4",
      fixture_path("dedupe_source_no_headers.csv"),
      "",
      "n",
      fixture_path("dedupe_reference_no_headers.csv"),
      "",
      "n",
      "1",
      "1",
      "",
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    refute_includes output.string, "customer_id,name"
    assert_includes output.string, "1,Alice"
    assert_includes output.string, "3,Cara"
    assert_includes output.string, "Summary: source_rows=5 removed_rows=3 kept_rows=2"
  end

  def test_parity_workflow_reports_match_and_returns_to_menu
    output = StringIO.new
    input = [
      "5",
      fixture_path("sample_people.csv"),
      fixture_path("sample_people.csv"),
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Left CSV file path:"
    assert_includes output.string, "Right CSV file path:"
    assert_includes output.string, "MATCH"
    assert_includes output.string, "Summary: left_rows=3 right_rows=3 left_only=0 right_only=0"
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_parity_workflow_supports_tsv_separator
    output = StringIO.new
    input = [
      "5",
      fixture_path("sample_people.tsv"),
      fixture_path("parity_people_reordered.tsv"),
      "2",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "MATCH"
    assert_includes output.string, "Summary: left_rows=3 right_rows=3 left_only=0 right_only=0"
  end

  def test_parity_workflow_headerless_mode_compares_all_rows
    output = StringIO.new
    input = [
      "5",
      fixture_path("sample_people_no_headers.csv"),
      fixture_path("sample_people_no_headers.csv"),
      "",
      "n",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "MATCH"
    assert_includes output.string, "Summary: left_rows=3 right_rows=3 left_only=0 right_only=0"
  end

  def test_parity_workflow_reports_header_mismatch_in_headered_mode
    output = StringIO.new
    input = [
      "5",
      fixture_path("sample_people.csv"),
      fixture_path("parity_people_header_mismatch.csv"),
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "CSV headers do not match."
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
  end

  def test_parity_workflow_prints_mismatch_examples_and_counts
    output = StringIO.new
    input = [
      "5",
      fixture_path("sample_people.csv"),
      fixture_path("parity_people_mismatch.csv"),
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "MISMATCH"
    assert_includes output.string, "Summary: left_rows=3 right_rows=3 left_only=1 right_only=1"
    assert_includes output.string, "Left-only examples:"
    assert_includes output.string, "Cara,Berlin (count +1)"
    assert_includes output.string, "Right-only examples:"
    assert_includes output.string, "Dina,Rome (count +1)"
  end

  def test_parity_workflow_missing_left_file_returns_to_menu
    output = StringIO.new
    input = [
      "5",
      "/tmp/not-there-left.csv",
      fixture_path("sample_people.csv"),
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "File not found: /tmp/not-there-left.csv"
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
    refute_includes output.string, "Traceback"
  end

  def test_parity_workflow_missing_right_file_returns_to_menu
    output = StringIO.new
    input = [
      "5",
      fixture_path("sample_people.csv"),
      "/tmp/not-there-right.csv",
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "File not found: /tmp/not-there-right.csv"
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
    refute_includes output.string, "Traceback"
  end

  def test_parity_workflow_malformed_csv_returns_to_menu
    output = StringIO.new
    input = [
      "5",
      fixture_path("sample_people.csv"),
      fixture_path("sample_people_bad_tail.csv"),
      "",
      "",
      "8"
    ].join("\n") + "\n"

    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Could not parse CSV file."
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
    refute_includes output.string, "Traceback"
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
        "8"
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
      "8"
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
      stdin: StringIO.new("1\n/tmp/does-not-exist.csv\n4\n7\n"),
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
      "8"
    ].join("\n") + "\n"

    output = StringIO.new
    status = Csvtool::CLI.start(["menu"], stdin: StringIO.new(input), stdout: output, stderr: StringIO.new)

    assert_equal 0, status
    assert_includes output.string, "Cannot write output file: /tmp/not-a-dir/out.csv"
    assert_operator output.string.scan("CSV Tool Menu").length, :>=, 2
  end
end
