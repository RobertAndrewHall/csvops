# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module Output
      class CsvCrossCsvDedupeFileWriter
        def initialize(deduper:)
          @deduper = deduper
        end

        def call(path:, headers:, col_sep:, dedupe_options:)
          stats = nil
          ::CSV.open(path, "w", write_headers: !headers.nil?, headers: headers, col_sep: col_sep) do |csv|
            stats = @deduper.each_retained(**dedupe_options) { |fields| csv << fields }
          end
          stats
        end
      end
    end
  end
end
