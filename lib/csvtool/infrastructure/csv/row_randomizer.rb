# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module CSV
      class RowRandomizer
        def initialize(rng: Random.new)
          @rng = rng
        end

        def call(file_path:, col_sep:, headers:)
          rows = []

          ::CSV.foreach(file_path, headers: headers, col_sep: col_sep) do |row|
            rows << (headers ? row.fields : row)
          end

          randomized = rows.map { |fields| [@rng.rand, fields] }.sort_by(&:first).map(&:last)
          randomized = randomized.rotate(1) if randomized.length > 1 && randomized == rows
          randomized
        end
      end
    end
  end
end
