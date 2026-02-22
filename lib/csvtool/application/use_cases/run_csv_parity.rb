# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/csv_parity_comparator"

module Csvtool
  module Application
    module UseCases
      class RunCsvParity
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def initialize(comparator: Infrastructure::CSV::CsvParityComparator.new)
          @comparator = comparator
        end

        def call(left_path:, right_path:, col_sep: ",", headers_present: true)
          return failure(:file_not_found, path: left_path) unless File.file?(left_path)
          return failure(:file_not_found, path: right_path) unless File.file?(right_path)

          stats = @comparator.call(
            left_path: left_path,
            right_path: right_path,
            col_sep: col_sep,
            headers_present: headers_present
          )

          success(stats)
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES => e
          failure(:cannot_read_file, path: e.respond_to?(:path) ? e.path : left_path)
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
