# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/csv_stats_scanner"
require "csvtool/infrastructure/output/csv_stats_file_writer"

module Csvtool
  module Application
    module UseCases
      class RunCsvStats
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def initialize(
          scanner: Infrastructure::CSV::CsvStatsScanner.new,
          csv_stats_file_writer: Infrastructure::Output::CsvStatsFileWriter.new
        )
          @scanner = scanner
          @csv_stats_file_writer = csv_stats_file_writer
        end

        def call(session:)
          path = session.source.path
          return failure(:file_not_found, path: path) unless File.file?(path)

          stats = @scanner.call(
            file_path: path,
            col_sep: session.source.separator,
            headers_present: session.source.headers_present
          )
          if session.output_destination&.file?
            @csv_stats_file_writer.call(path: session.output_destination.path, data: stats)
            return success(stats.merge(output_path: session.output_destination.path))
          end
          success(stats)
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES => e
          if session.output_destination&.file?
            return failure(:cannot_write_output_file, path: session.output_destination.path, error_class: e.class)
          end
          failure(:cannot_read_file, path: path)
        rescue Errno::ENOENT => e
          return failure(:cannot_write_output_file, path: session.output_destination.path, error_class: e.class) if session.output_destination&.file?

          failure(:cannot_read_file, path: path)
        end

        private

        def success(data)
          Result.new(ok: true, error: nil, data: data)
        end

        def failure(code, data = {})
          Result.new(ok: false, error: code, data: data)
        end
      end
    end
  end
end
