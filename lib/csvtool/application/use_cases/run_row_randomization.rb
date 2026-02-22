# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/row_randomizer"

module Csvtool
  module Application
    module UseCases
      class RunRowRandomization
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def initialize(
          header_reader: Infrastructure::CSV::HeaderReader.new,
          row_randomizer: Infrastructure::CSV::RowRandomizer.new
        )
          @header_reader = header_reader
          @row_randomizer = row_randomizer
        end

        def read_headers(file_path:, col_sep:, headers_present:)
          return failure(:file_not_found, path: file_path) unless File.file?(file_path)

          headers = nil
          if headers_present
            headers = @header_reader.call(file_path: file_path, col_sep: col_sep)
            return failure(:no_headers) if headers.empty?
          end

          success(headers: headers)
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES
          failure(:cannot_read_file, path: file_path)
        end

        def randomize(session:, headers:, on_row: nil)
          if session.output_destination.file?
            write_file(
              path: session.output_destination.path,
              headers: headers,
              file_path: session.source.path,
              col_sep: session.source.separator,
              headers_present: session.source.headers_present?,
              seed: session.options.seed
            )
          else
            @row_randomizer.each(
              file_path: session.source.path,
              col_sep: session.source.separator,
              headers: session.source.headers_present?,
              seed: session.options.seed
            ) { |fields| on_row.call(fields) if on_row }
            success({})
          end
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES
          failure(:cannot_read_file, path: session.source.path)
        end

        private

        def write_file(path:, headers:, file_path:, col_sep:, headers_present:, seed:)
          ::CSV.open(path, "w", write_headers: !headers.nil?, headers: headers, col_sep: col_sep) do |csv|
            @row_randomizer.each(file_path: file_path, col_sep: col_sep, headers: headers_present, seed: seed) do |fields|
              csv << fields
            end
          end
          success(output_path: path)
        rescue Errno::EACCES, Errno::ENOENT => e
          failure(:cannot_write_output_file, path: path, error_class: e.class)
        end

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
