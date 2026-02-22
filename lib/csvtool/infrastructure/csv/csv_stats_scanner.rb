# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module CSV
      class CsvStatsScanner
        def call(file_path:, col_sep:, headers_present:)
          data_row_count = 0
          headers = nil
          column_count = 0

          ::CSV.foreach(file_path, headers: headers_present, col_sep: col_sep) do |row|
            if headers_present
              headers ||= row.headers
              column_count = headers.length
              data_row_count += 1
            else
              fields = row.is_a?(::CSV::Row) ? row.fields : row
              column_count = [column_count, fields.length].max
              data_row_count += 1
            end
          end

          {
            row_count: data_row_count,
            column_count: column_count,
            headers: headers
          }
        end
      end
    end
  end
end
