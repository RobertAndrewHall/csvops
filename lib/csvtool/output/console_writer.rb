# frozen_string_literal: true

module Csvtool
  module Output
    class ConsoleWriter
      def initialize(stdout:, value_streamer:)
        @stdout = stdout
        @value_streamer = value_streamer
      end

      def call(file_path:, column_name:, col_sep:, skip_blanks:)
        @value_streamer.each(file_path: file_path, column_name: column_name, col_sep: col_sep, skip_blanks: skip_blanks) do |value|
          @stdout.puts value
        end
      end
    end
  end
end
