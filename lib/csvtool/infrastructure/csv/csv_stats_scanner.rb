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
          column_stats = []

          ::CSV.foreach(file_path, headers: headers_present, col_sep: col_sep) do |row|
            if headers_present
              headers ||= row.headers
              column_count = headers.length
              if column_stats.empty?
                column_stats = headers.map { |name| { name: name, blank_count: 0, non_blank_count: 0 } }
              end
              fields = row.fields
              fields.fill(nil, fields.length...column_count)
              fields.each_with_index { |value, index| apply_value(column_stats[index], value) }
              data_row_count += 1
            else
              fields = row.is_a?(::CSV::Row) ? row.fields : row
              column_count = [column_count, fields.length].max
              while column_stats.length < column_count
                column_stats << {
                  name: "column_#{column_stats.length + 1}",
                  blank_count: 0,
                  non_blank_count: 0
                }
              end
              fields.fill(nil, fields.length...column_count)
              fields.each_with_index { |value, index| apply_value(column_stats[index], value) }
              data_row_count += 1
            end
          end

          {
            row_count: data_row_count,
            column_count: column_count,
            headers: headers,
            column_stats: column_stats
          }
        end

        private

        def apply_value(stats, value)
          if value.nil? || value.strip.empty?
            stats[:blank_count] += 1
          else
            stats[:non_blank_count] += 1
          end
        end
      end
    end
  end
end
