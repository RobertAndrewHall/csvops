# frozen_string_literal: true

require "csv"
require "set"

module Csvtool
  module Infrastructure
    module CSV
      class CrossCsvDeduper
        def call(
          source_path:,
          reference_path:,
          source_selector:,
          reference_selector:,
          source_col_sep: ",",
          reference_col_sep: ",",
          source_has_headers: true,
          reference_has_headers: true,
          trim_whitespace: true,
          case_insensitive: false
        )
          reference_keys = Set.new
          ::CSV.foreach(reference_path, headers: reference_has_headers, col_sep: reference_col_sep) do |row|
            reference_keys << extract_key(
              row,
              selector: reference_selector,
              headers: reference_has_headers,
              trim_whitespace: trim_whitespace,
              case_insensitive: case_insensitive
            )
          end

          source_header_row = nil
          kept_rows = []
          source_rows = 0
          removed_rows = 0

          ::CSV.foreach(source_path, headers: source_has_headers, col_sep: source_col_sep) do |row|
            source_header_row ||= row.headers if source_has_headers
            source_rows += 1
            key = extract_key(
              row,
              selector: source_selector,
              headers: source_has_headers,
              trim_whitespace: trim_whitespace,
              case_insensitive: case_insensitive
            )
            if reference_keys.include?(key)
              removed_rows += 1
            else
              kept_rows << (source_has_headers ? row.fields : row)
            end
          end

          {
            headers: source_has_headers ? (source_header_row || []) : nil,
            kept_rows: kept_rows,
            source_rows: source_rows,
            removed_rows: removed_rows,
            kept_rows_count: kept_rows.length
          }
        end

        private

        def extract_key(row, selector:, headers:, trim_whitespace:, case_insensitive:)
          raw_key = if headers
                      row[selector].to_s
                    else
                      row[selector - 1].to_s
                    end

          normalize_key(raw_key, trim_whitespace: trim_whitespace, case_insensitive: case_insensitive)
        end

        def normalize_key(key, trim_whitespace:, case_insensitive:)
          value = trim_whitespace ? key.strip : key
          case_insensitive ? value.downcase : value
        end
      end
    end
  end
end
