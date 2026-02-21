# frozen_string_literal: true

require "csv"

module Csvtool
  module Output
    class CsvFileWriter
      def initialize(stdout:, errors:, value_streamer:)
        @stdout = stdout
        @errors = errors
        @value_streamer = value_streamer
      end

      def call(file_path:, column_name:, col_sep:, skip_blanks:, output_path:)
        CSV.open(output_path, "w") do |csv|
          csv << [column_name]
          @value_streamer.each(file_path: file_path, column_name: column_name, col_sep: col_sep, skip_blanks: skip_blanks) do |value|
            csv << [value]
          end
        end

        @stdout.puts "Wrote output to #{output_path}"
      rescue Errno::EACCES, Errno::ENOENT => e
        @errors.cannot_write_output_file(output_path, e.class)
      end
    end
  end
end
