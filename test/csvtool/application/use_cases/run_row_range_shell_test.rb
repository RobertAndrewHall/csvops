# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_row_range_shell"
require "tmpdir"

class RunRowRangeShellTest < Minitest::Test
  def test_use_case_prints_selected_row_range_with_header
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    input = [fixture, "", "2", "3", ""].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "name,city"
    assert_includes out.string, "Bob,Paris"
    assert_includes out.string, "Cara,Berlin"
    refute_includes out.string, "Alice,London"
  end

  def test_rejects_non_numeric_start_row
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    input = [fixture, "", "abc", "3", ""].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "Start row must be a positive integer."
    refute_includes out.string, "name,city"
  end

  def test_rejects_non_numeric_end_row
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    input = [fixture, "", "1", "xyz", ""].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "End row must be a positive integer."
    refute_includes out.string, "name,city"
  end

  def test_rejects_end_before_start
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    input = [fixture, "", "3", "2", ""].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "End row must be greater than or equal to start row."
    refute_includes out.string, "name,city"
  end

  def test_handles_out_of_bounds_start_row
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)
    input = [fixture, "", "10", "12", ""].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "Row range is out of bounds. File has 3 data rows."
    refute_includes out.string, "name,city"
  end

  def test_use_case_supports_tsv_separator
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.tsv", __dir__)
    input = [fixture, "2", "2", "3", ""].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "name,city"
    assert_includes out.string, "Bob,Paris"
    assert_includes out.string, "Cara,Berlin"
  end

  def test_use_case_supports_custom_separator
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people_colon.txt", __dir__)
    input = [fixture, "5", ":", "2", "3", ""].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "name,city"
    assert_includes out.string, "Bob,Paris"
    assert_includes out.string, "Cara,Berlin"
  end

  def test_use_case_can_write_selected_rows_to_file
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "rows.csv")
      input = [fixture, "", "2", "3", "2", output_path].join("\n") + "\n"

      use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
      use_case.call

      assert_equal "name,city\nBob,Paris\nCara,Berlin\n", File.read(output_path)
      assert_includes out.string, "Wrote output to #{output_path}"
    end
  end

  def test_stops_parsing_after_end_row_for_console_output
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people_bad_tail.csv", __dir__)
    input = [fixture, "", "1", "2", ""].join("\n") + "\n"

    use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
    use_case.call

    assert_includes out.string, "name,city"
    assert_includes out.string, "Alice,London"
    assert_includes out.string, "Bob,Paris"
    refute_includes out.string, "Could not parse CSV file."
  end

  def test_out_of_bounds_file_mode_reports_error
    out = StringIO.new
    fixture = File.expand_path("../../../fixtures/sample_people.csv", __dir__)

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "rows.csv")
      input = [fixture, "", "10", "12", "2", output_path].join("\n") + "\n"

      use_case = Csvtool::Application::UseCases::RunRowRangeShell.new(stdin: StringIO.new(input), stdout: out)
      use_case.call
    end

    assert_includes out.string, "Row range is out of bounds. File has 3 data rows."
  end
end
