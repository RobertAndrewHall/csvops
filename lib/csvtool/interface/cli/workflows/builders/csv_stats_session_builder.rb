# frozen_string_literal: true

require "csvtool/domain/csv_stats_session/stats_source"
require "csvtool/domain/csv_stats_session/stats_options"
require "csvtool/domain/csv_stats_session/stats_session"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Builders
          class CsvStatsSessionBuilder
            def call(file_path:, col_sep:, headers_present:, destination:)
              source = Domain::CsvStatsSession::StatsSource.new(
                path: file_path,
                separator: col_sep,
                headers_present: headers_present
              )
              options = Domain::CsvStatsSession::StatsOptions.new
              session = Domain::CsvStatsSession::StatsSession.start(source: source, options: options)
              session.with_output_destination(destination)
            end
          end
        end
      end
    end
  end
end
