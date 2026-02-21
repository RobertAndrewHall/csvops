# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/infrastructure/csv/row_streamer"

class InfrastructureRowStreamerTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../../fixtures/#{name}", __dir__)
  end

  def test_streams_only_requested_row_range
    streamer = Csvtool::Infrastructure::CSV::RowStreamer.new
    rows = []

    stats = streamer.each_in_range(
      file_path: fixture_path("sample_people.csv"),
      col_sep: ",",
      start_row: 2,
      end_row: 3
    ) { |fields| rows << fields }

    assert_equal [["Bob", "Paris"], ["Cara", "Berlin"]], rows
    assert_equal true, stats[:matched]
    assert_equal 3, stats[:row_count]
  end

  def test_stops_before_malformed_tail_when_end_row_reached
    streamer = Csvtool::Infrastructure::CSV::RowStreamer.new
    rows = []

    stats = streamer.each_in_range(
      file_path: fixture_path("sample_people_bad_tail.csv"),
      col_sep: ",",
      start_row: 1,
      end_row: 2
    ) { |fields| rows << fields }

    assert_equal [["Alice", "London"], ["Bob", "Paris"]], rows
    assert_equal true, stats[:matched]
  end
end
