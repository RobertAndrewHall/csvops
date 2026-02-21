# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module CSV
      class RowStreamer
        def each_in_range(file_path:, col_sep:, start_row:, end_row:)
          row_index = 0
          matched = false

          ::CSV.foreach(file_path, headers: true, col_sep: col_sep) do |row|
            row_index += 1
            next if row_index < start_row
            break if row_index > end_row

            matched = true
            yield row.fields
          end

          { matched: matched, row_count: row_index }
        end
      end
    end
  end
end
