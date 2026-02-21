# frozen_string_literal: true

module Csvtool
  module Services
    class PreviewBuilder
      def initialize(value_streamer:)
        @value_streamer = value_streamer
      end

      def call(file_path:, column_name:, col_sep:, skip_blanks:, limit:)
        preview_values = []
        @value_streamer.each(file_path: file_path, column_name: column_name, col_sep: col_sep, skip_blanks: skip_blanks) do |value|
          preview_values << value
          break if preview_values.length >= limit
        end
        preview_values
      end
    end
  end
end
