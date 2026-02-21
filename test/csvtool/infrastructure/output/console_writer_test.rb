# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/output/console_writer"

class InfrastructureConsoleWriterTest < Minitest::Test
  class FakeStreamer
    def each(file_path:, column_name:, col_sep:, skip_blanks:)
      %w[Alice Bob].each { |value| yield value }
    end
  end

  def test_writes_streamed_values_to_stdout
    out = StringIO.new
    writer = Csvtool::Infrastructure::Output::ConsoleWriter.new(stdout: out, value_streamer: FakeStreamer.new)
    writer.call(file_path: "x.csv", column_name: "name", col_sep: ",", skip_blanks: true)
    assert_equal "Alice\nBob\n", out.string
  end
end
