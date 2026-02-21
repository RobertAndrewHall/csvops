# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/errors/presenter"

class ErrorsPresenterTest < Minitest::Test
  def test_all_messages_are_presented
    out = StringIO.new
    presenter = Csvtool::Interface::CLI::Errors::Presenter.new(stdout: out)

    presenter.file_not_found("/tmp/x.csv")
    presenter.no_headers
    presenter.column_not_found
    presenter.could_not_parse_csv
    presenter.cannot_read_file("/tmp/y.csv")
    presenter.cannot_write_output_file("/tmp/z.csv", Errno::ENOENT)
    presenter.empty_output_path
    presenter.invalid_output_destination
    presenter.empty_custom_separator
    presenter.invalid_separator_choice
    presenter.invalid_seed
    presenter.canceled
    presenter.invalid_start_row
    presenter.invalid_end_row
    presenter.invalid_row_range_order
    presenter.row_range_out_of_bounds(3)

    text = out.string
    assert_includes text, "File not found: /tmp/x.csv"
    assert_includes text, "No headers found."
    assert_includes text, "Column not found."
    assert_includes text, "Could not parse CSV file."
    assert_includes text, "Cannot read file: /tmp/y.csv"
    assert_includes text, "Cannot write output file: /tmp/z.csv (Errno::ENOENT)"
    assert_includes text, "Output file path cannot be empty."
    assert_includes text, "Invalid output destination."
    assert_includes text, "Separator cannot be empty."
    assert_includes text, "Invalid separator choice."
    assert_includes text, "Seed must be an integer."
    assert_includes text, "Canceled."
    assert_includes text, "Start row must be a positive integer."
    assert_includes text, "End row must be a positive integer."
    assert_includes text, "End row must be greater than or equal to start row."
    assert_includes text, "Row range is out of bounds. File has 3 data rows."
  end
end
