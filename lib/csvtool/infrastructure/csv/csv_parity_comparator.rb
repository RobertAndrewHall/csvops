# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module CSV
      class CsvParityComparator
        def call(left_path:, right_path:, col_sep:, headers_present:, sample_limit: 5)
          left_counts, left_rows = row_counts(path: left_path, col_sep: col_sep, headers_present: headers_present)
          right_counts, right_rows = row_counts(path: right_path, col_sep: col_sep, headers_present: headers_present)

          left_only_count = 0
          right_only_count = 0
          left_only_examples = []
          right_only_examples = []

          (left_counts.keys | right_counts.keys).each do |key|
            diff = left_counts[key] - right_counts[key]
            if diff.positive?
              left_only_count += diff
              left_only_examples << { row: key, count_delta: diff } if left_only_examples.length < sample_limit
            elsif diff.negative?
              right_only_count += -diff
              right_only_examples << { row: key, count_delta: -diff } if right_only_examples.length < sample_limit
            end
          end

          {
            match: left_only_count.zero? && right_only_count.zero?,
            left_rows: left_rows,
            right_rows: right_rows,
            left_only_count: left_only_count,
            right_only_count: right_only_count,
            left_only_examples: left_only_examples,
            right_only_examples: right_only_examples
          }
        end

        private

        def row_counts(path:, col_sep:, headers_present:)
          counts = Hash.new(0)
          rows = 0

          ::CSV.foreach(path, headers: headers_present, col_sep: col_sep) do |row|
            fields = headers_present ? row.fields : row
            counts[serialize(fields: fields, col_sep: col_sep)] += 1
            rows += 1
          end

          [counts, rows]
        end

        def serialize(fields:, col_sep:)
          ::CSV.generate_line(fields, row_sep: "", col_sep: col_sep).chomp
        end
      end
    end
  end
end
