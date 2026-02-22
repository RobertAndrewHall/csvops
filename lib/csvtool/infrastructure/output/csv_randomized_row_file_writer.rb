# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module Output
      class CsvRandomizedRowFileWriter
        def initialize(row_randomizer:)
          @row_randomizer = row_randomizer
        end

        def call(path:, headers:, file_path:, col_sep:, headers_present:, seed:)
          ::CSV.open(path, "w", write_headers: !headers.nil?, headers: headers, col_sep: col_sep) do |csv|
            @row_randomizer.each(file_path: file_path, col_sep: col_sep, headers: headers_present, seed: seed) do |fields|
              csv << fields
            end
          end
        end
      end
    end
  end
end
