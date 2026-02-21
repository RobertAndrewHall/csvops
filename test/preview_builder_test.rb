# frozen_string_literal: true

require_relative "test_helper"
require "csvtool/services/preview_builder"

class PreviewBuilderTest < Minitest::Test
  class FakeStreamer
    def initialize(values)
      @values = values
    end

    def each(file_path:, column_name:, col_sep:, skip_blanks:)
      @values.each { |value| yield value }
    end
  end

  def test_builds_preview_up_to_limit
    builder = Csvtool::Services::PreviewBuilder.new(value_streamer: FakeStreamer.new(%w[a b c d]))
    preview = builder.call(file_path: "x.csv", column_name: "name", col_sep: ",", skip_blanks: true, limit: 2)
    assert_equal %w[a b], preview
  end
end
