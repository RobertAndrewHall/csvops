# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module Output
      class CsvSplitManifestWriter
        def call(path:, chunk_paths:, chunk_row_counts:)
          ::CSV.open(path, "w") do |csv|
            csv << %w[chunk_index chunk_path row_count]
            chunk_paths.each_with_index do |chunk_path, index|
              csv << [index + 1, chunk_path, chunk_row_counts[index]]
            end
          end
        end
      end
    end
  end
end
