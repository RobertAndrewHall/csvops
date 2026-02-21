# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/output/csv_file_writer"
require "csvtool/interface/cli/errors/presenter"
require "tmpdir"

class InfrastructureCsvFileWriterTest < Minitest::Test
  class FakeStreamer
    def each(file_path:, column_name:, col_sep:, skip_blanks:)
      %w[Alice Bob].each { |value| yield value }
    end
  end

  def test_writes_header_and_values
    stdout = StringIO.new
    writer = Csvtool::Infrastructure::Output::CsvFileWriter.new(
      stdout: stdout,
      errors: Csvtool::Interface::CLI::Errors::Presenter.new(stdout: stdout),
      value_streamer: FakeStreamer.new
    )

    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "names.csv")
      writer.call(
        file_path: "ignored.csv",
        column_name: "name",
        col_sep: ",",
        skip_blanks: true,
        output_path: output_path
      )
      assert_equal "name\nAlice\nBob\n", File.read(output_path)
    end
  end
end
