# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/csv_parity_comparator"
require "csvtool/infrastructure/csv/header_reader"

module Csvtool
  module Application
    module UseCases
      class RunCsvParity
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def initialize(
          comparator: Infrastructure::CSV::CsvParityComparator.new,
          header_reader: Infrastructure::CSV::HeaderReader.new
        )
          @comparator = comparator
          @header_reader = header_reader
        end

        def call(session:)
          left_path = session.source_pair.left_path
          right_path = session.source_pair.right_path
          col_sep = session.options.separator
          headers_present = session.options.headers_present?

          return failure(:file_not_found, path: left_path) unless File.file?(left_path)
          return failure(:file_not_found, path: right_path) unless File.file?(right_path)

          if headers_present
            left_headers = @header_reader.call(file_path: left_path, col_sep: col_sep)
            return failure(:no_headers, path: left_path) if left_headers.empty?

            right_headers = @header_reader.call(file_path: right_path, col_sep: col_sep)
            return failure(:no_headers, path: right_path) if right_headers.empty?

            return failure(:header_mismatch, left_headers: left_headers, right_headers: right_headers) unless left_headers == right_headers
          end

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
