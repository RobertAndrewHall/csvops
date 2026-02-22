# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module Output
      class CsvRowFileWriter
        def initialize(row_streamer:)
          @row_streamer = row_streamer
        end

        def call(file_path:, col_sep:, headers:, start_row:, end_row:, output_path:)
          csv = nil
          wrote_rows = false

          stats = @row_streamer.each_in_range(
            file_path: file_path,
            col_sep: col_sep,
            start_row: start_row,
            end_row: end_row
          ) do |fields|
            unless wrote_rows
              csv = ::CSV.open(output_path, "w")
              csv << headers
              wrote_rows = true
            end
            csv << fields
          end

          stats.merge(wrote_rows: wrote_rows)
        ensure
          csv&.close unless csv&.closed?
        end
      end
    end
  end
end
