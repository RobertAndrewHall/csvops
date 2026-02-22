# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module Output
      class CsvStatsFileWriter
        def call(path:, data:)
          ::CSV.open(path, "w") do |csv|
            csv << %w[metric value]
            csv << ["row_count", data[:row_count]]
            csv << ["column_count", data[:column_count]]
            unless data[:headers].nil? || data[:headers].empty?
              csv << ["headers", data[:headers].join("|")]
            end
            data.fetch(:column_stats, []).each do |stats|
              csv << ["column.#{stats[:name]}.non_blank", stats[:non_blank_count]]
              csv << ["column.#{stats[:name]}.blank", stats[:blank_count]]
            end
          end
        end
      end
    end
  end
end
