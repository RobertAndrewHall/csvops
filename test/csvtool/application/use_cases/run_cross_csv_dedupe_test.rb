# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_cross_csv_dedupe"

class RunCrossCsvDedupeTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_dedupes_source_rows_by_reference_column
    output = StringIO.new
    input = [
      fixture_path("dedupe_source.csv"),
      fixture_path("dedupe_reference.csv"),
      "customer_id",
      "external_id"
    ].join("\n") + "\n"

    Csvtool::Application::UseCases::RunCrossCsvDedupe.new(stdin: StringIO.new(input), stdout: output).call

    assert_includes output.string, "CSV file path:"
    assert_includes output.string, "Reference CSV file path:"
    assert_includes output.string, "Source key column name:"
    assert_includes output.string, "Reference key column name:"
    assert_includes output.string, "customer_id,name"
    assert_includes output.string, "1,Alice"
    assert_includes output.string, "3,Cara"
    refute_includes output.string, "2,Bob"
    refute_includes output.string, "4,Dan"
    assert_includes output.string, "Summary: source_rows=5 removed_rows=3 kept_rows=2"
  end
end
