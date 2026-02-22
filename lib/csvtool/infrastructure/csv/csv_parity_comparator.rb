# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module CSV
      class CsvParityComparator
        def call(left_path:, right_path:, col_sep:, headers_present:, sample_limit: 5)
          deltas = Hash.new(0)
          left_rows = stream_rows(path: left_path, col_sep: col_sep, headers_present: headers_present) do |key|
            deltas[key] += 1
          end
          right_rows = stream_rows(path: right_path, col_sep: col_sep, headers_present: headers_present) do |key|
            deltas[key] -= 1
          end

          left_only_count, right_only_count, left_only_examples, right_only_examples =
            mismatch_totals_and_samples(deltas: deltas, sample_limit: sample_limit)

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

        def stream_rows(path:, col_sep:, headers_present:)
          rows = 0

          ::CSV.foreach(path, headers: headers_present, col_sep: col_sep) do |row|
            fields = headers_present ? row.fields : row
            yield serialize(fields: fields, col_sep: col_sep)
            rows += 1
          end

          rows
        end

        def mismatch_totals_and_samples(deltas:, sample_limit:)
          left_only_count = 0
          right_only_count = 0
          left_only_examples = []
          right_only_examples = []

          deltas.each do |key, delta|
            if delta.positive?
              left_only_count += delta
              left_only_examples << { row: key, count_delta: delta } if left_only_examples.length < sample_limit
            elsif delta.negative?
              right_only_count += -delta
              right_only_examples << { row: key, count_delta: -delta } if right_only_examples.length < sample_limit
            end
          end

          [left_only_count, right_only_count, left_only_examples, right_only_examples]
        end

        def serialize(fields:, col_sep:)
          ::CSV.generate_line(fields, row_sep: "", col_sep: col_sep).chomp
        end
      end
    end
  end
end
