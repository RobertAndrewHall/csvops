# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/shared/output_destination"

class SharedOutputDestinationTest < Minitest::Test
  def test_builds_console_and_file_destinations
    console = Csvtool::Domain::Shared::OutputDestination.console
    file = Csvtool::Domain::Shared::OutputDestination.file(path: "/tmp/out.csv")

    assert_equal true, console.console?
    assert_equal false, console.file?
    assert_equal true, file.file?
    assert_equal "/tmp/out.csv", file.path
  end

  def test_rejects_empty_file_path
    error = assert_raises(ArgumentError) do
      Csvtool::Domain::Shared::OutputDestination.file(path: "")
    end

    assert_equal "file output path cannot be empty", error.message
  end
end
