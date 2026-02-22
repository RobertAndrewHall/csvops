# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/workflows/run_cross_csv_dedupe_workflow"
require "tmpdir"

class RunCrossCsvDedupeWorkflowTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../../fixtures/#{name}", __dir__)
  end

  def test_dedupes_source_rows_by_reference_column
    output = StringIO.new
    input = [
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
      ""
    ].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow
      .new(stdin: StringIO.new(input), stdout: output)
      .call

    assert_includes output.string, "CSV file path:"
    assert_includes output.string, "Reference CSV file path:"
    assert_includes output.string, "Source key column name:"
    assert_includes output.string, "Reference key column name:"
    assert_includes output.string, "customer_id,name"
    assert_includes output.string, "1,Alice"
    assert_includes output.string, "3,Cara"
    refute_includes output.string, "2,Bob"
    refute_includes output.string, "4,Dan"
    assert_includes output.string, "Summary"
    assert_includes output.string, "Source rows"
    assert_includes output.string, "Removed rows"
    assert_includes output.string, "Kept rows"
  end

  def test_can_write_deduped_rows_to_file
    output = StringIO.new

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "deduped.csv")
      input = [
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
        output_path
      ].join("\n") + "\n"

      Csvtool::Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow
        .new(stdin: StringIO.new(input), stdout: output)
        .call

      assert_includes output.string, "Wrote output to #{output_path}"
      assert_equal "customer_id,name\n1,Alice\n3,Cara\n", File.read(output_path)
      assert_includes output.string, "Summary"
    end
  end

  def test_supports_tsv_separators
    output = StringIO.new
    input = [
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
      ""
    ].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow
      .new(stdin: StringIO.new(input), stdout: output)
      .call

    assert_includes output.string, "customer_id\tname"
    assert_includes output.string, "1\tAlice"
    assert_includes output.string, "3\tCara"
  end

  def test_headerless_mode_supports_column_index
    output = StringIO.new
    input = [
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
      ""
    ].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow
      .new(stdin: StringIO.new(input), stdout: output)
      .call

    refute_includes output.string, "customer_id,name"
    assert_includes output.string, "1,Alice"
    assert_includes output.string, "3,Cara"
    assert_includes output.string, "Summary"
  end

  def test_reports_column_not_found_when_missing
    output = StringIO.new
    input = [
      fixture_path("dedupe_source.csv"),
      "",
      "",
      fixture_path("dedupe_reference.csv"),
      "",
      "",
      "missing",
      "external_id",
      "",
      ""
    ].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow
      .new(stdin: StringIO.new(input), stdout: output)
      .call

    assert_includes output.string, "Column not found."
  end

  def test_reports_when_no_rows_were_removed
    output = StringIO.new
    input = [
      fixture_path("dedupe_source.csv"),
      "",
      "",
      fixture_path("dedupe_reference_none.csv"),
      "",
      "",
      "customer_id",
      "external_id",
      "",
      "",
      ""
    ].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow
      .new(stdin: StringIO.new(input), stdout: output)
      .call

    assert_includes output.string, "Summary"
    assert_includes output.string, "No rows removed; no matching keys found."
  end

  def test_reports_when_all_rows_were_removed
    output = StringIO.new
    input = [
      fixture_path("dedupe_source.csv"),
      "",
      "",
      fixture_path("dedupe_reference_all.csv"),
      "",
      "",
      "customer_id",
      "external_id",
      "",
      "",
      ""
    ].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow
      .new(stdin: StringIO.new(input), stdout: output)
      .call

    assert_includes output.string, "Summary"
    assert_includes output.string, "All source rows were removed by dedupe."
  end

  def test_normalization_trim_on_and_case_insensitive_on_matches_equivalent_keys
    output = StringIO.new
    input = [
      fixture_path("dedupe_source_normalization.csv"),
      "",
      "",
      fixture_path("dedupe_reference_normalization.csv"),
      "",
      "",
      "customer_id",
      "external_id",
      "",
      "y",
      ""
    ].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow
      .new(stdin: StringIO.new(input), stdout: output)
      .call

    refute_includes output.string, " A1 ,Alice"
    refute_includes output.string, "c3,Cara"
    assert_includes output.string, "B2,Bob"
    assert_includes output.string, "Summary"
  end

  def test_normalization_disabled_preserves_exact_match_behavior
    output = StringIO.new
    input = [
      fixture_path("dedupe_source_normalization.csv"),
      "",
      "",
      fixture_path("dedupe_reference_normalization.csv"),
      "",
      "",
      "customer_id",
      "external_id",
      "n",
      "n",
      ""
    ].join("\n") + "\n"

    Csvtool::Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow
      .new(stdin: StringIO.new(input), stdout: output)
      .call

    assert_includes output.string, " A1 ,Alice"
    assert_includes output.string, "B2,Bob"
    assert_includes output.string, "c3,Cara"
    assert_includes output.string, "Summary"
  end
end
