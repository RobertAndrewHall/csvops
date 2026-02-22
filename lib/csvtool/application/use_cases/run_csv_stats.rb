# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/csv_stats_scanner"

module Csvtool
  module Application
    module UseCases
      class RunCsvStats
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def initialize(scanner: Infrastructure::CSV::CsvStatsScanner.new)
          @scanner = scanner
        end

        def call(session:)
          path = session.source.path
          return failure(:file_not_found, path: path) unless File.file?(path)

          stats = @scanner.call(
            file_path: path,
            col_sep: session.source.separator,
            headers_present: session.source.headers_present
          )
          success(stats)
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES
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
