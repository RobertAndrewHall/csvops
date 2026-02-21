# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_randomization_session/randomization_output_destination"

class RandomizationOutputDestinationTest < Minitest::Test
  def test_console_and_file_modes
    console = Csvtool::Domain::RowRandomizationSession::RandomizationOutputDestination.console
    file = Csvtool::Domain::RowRandomizationSession::RandomizationOutputDestination.file(path: "/tmp/out.csv")

    assert_equal false, console.file?
    assert_equal true, file.file?
    assert_equal "/tmp/out.csv", file.path
  end

  def test_rejects_empty_file_path
    assert_raises(ArgumentError) do
      Csvtool::Domain::RowRandomizationSession::RandomizationOutputDestination.file(path: "")
    end
  end
end
