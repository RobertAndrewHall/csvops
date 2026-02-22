# frozen_string_literal: true

require_relative "../../../../test_helper"
require "csvtool/interface/cli/output/streams"

class StreamsTest < Minitest::Test
  def test_builds_data_and_ui_streams
    data = StringIO.new
    ui = StringIO.new

    streams = Csvtool::Interface::CLI::Output::Streams.build(data: data, ui: ui)

    assert_same data, streams.data
    assert_same ui, streams.ui
  end

  def test_defaults_ui_to_data_stream
    data = StringIO.new

    streams = Csvtool::Interface::CLI::Output::Streams.build(data: data)

    assert_same data, streams.data
    assert_same data, streams.ui
  end
end
