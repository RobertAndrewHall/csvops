# frozen_string_literal: true

require_relative "../../test_helper"
require "csvtool/services/value_streamer"

class ValueStreamerTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../fixtures/#{name}", __dir__)
  end

  def test_filters_blanks_when_enabled
    streamer = Csvtool::Services::ValueStreamer.new
    values = []
    streamer.each(
      file_path: fixture_path("sample_people_blanks.csv"),
      column_name: "name",
      col_sep: ",",
      skip_blanks: true
    ) { |v| values << v }
    assert_equal %w[Alice Bob Cara], values
  end

  def test_keeps_blanks_when_disabled
    streamer = Csvtool::Services::ValueStreamer.new
    values = []
    streamer.each(
      file_path: fixture_path("sample_people_blanks.csv"),
      column_name: "name",
      col_sep: ",",
      skip_blanks: false
    ) { |v| values << v }
    assert_equal ["Alice", " ", "", "Bob", "Cara"], values
  end
end
