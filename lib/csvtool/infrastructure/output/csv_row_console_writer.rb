# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module Output
      class CsvRowConsoleWriter
        def initialize(stdout:, row_streamer:)
          @stdout = stdout
          @row_streamer = row_streamer
        end

        def call(file_path:, col_sep:, headers:, start_row:, end_row:)
          wrote_header = false
          stats = @row_streamer.each_in_range(
            file_path: file_path,
            col_sep: col_sep,
            start_row: start_row,
            end_row: end_row
          ) do |fields|
            unless wrote_header
              @stdout.puts ::CSV.generate_line(headers, row_sep: "").chomp
              wrote_header = true
            end
            @stdout.puts ::CSV.generate_line(fields, row_sep: "").chomp
          end

          stats
        end
      end
    end
  end
end
