# frozen_string_literal: true

require "csv"
require "set"

module Csvtool
  module Infrastructure
    module CSV
      class CrossCsvDeduper
        def call(source_path:, reference_path:, source_column:, reference_column:, col_sep: ",")
          reference_keys = Set.new
          ::CSV.foreach(reference_path, headers: true, col_sep: col_sep) do |row|
            reference_keys << row[reference_column].to_s
          end

          source_headers = nil
          kept_rows = []
          source_rows = 0
          removed_rows = 0

          ::CSV.foreach(source_path, headers: true, col_sep: col_sep) do |row|
            source_headers ||= row.headers
            source_rows += 1
            key = row[source_column].to_s
            if reference_keys.include?(key)
              removed_rows += 1
            else
              kept_rows << row.fields
            end
          end

          {
            headers: source_headers || [],
            kept_rows: kept_rows,
            source_rows: source_rows,
            removed_rows: removed_rows,
            kept_rows_count: kept_rows.length
          }
        end
      end
    end
  end
end
