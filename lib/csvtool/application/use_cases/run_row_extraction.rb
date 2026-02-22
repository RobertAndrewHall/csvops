# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/row_streamer"
require "csvtool/infrastructure/output/csv_row_file_writer"

module Csvtool
  module Application
    module UseCases
      class RunRowExtraction
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def initialize(
          header_reader: Infrastructure::CSV::HeaderReader.new,
          row_streamer: Infrastructure::CSV::RowStreamer.new,
          csv_row_file_writer: nil
        )
          @header_reader = header_reader
          @row_streamer = row_streamer
          @csv_row_file_writer = csv_row_file_writer || Infrastructure::Output::CsvRowFileWriter.new(row_streamer: @row_streamer)
        end

        def read_headers(file_path:, col_sep:)
          return failure(:file_not_found, path: file_path) unless File.file?(file_path)

          headers = @header_reader.call(file_path: file_path, col_sep: col_sep)
          return failure(:no_headers) if headers.empty?

          success(headers: headers)
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES
          failure(:cannot_read_file, path: file_path)
        end

        def extract(session:, headers:, on_row: nil)
          if session.output_destination.file?
            stats = @csv_row_file_writer.call(
              output_path: session.output_destination.path,
              file_path: session.source.path,
              col_sep: session.source.separator,
              headers: headers,
              start_row: session.row_range.start_row,
              end_row: session.row_range.end_row
            )
            success(stats.merge(output_path: session.output_destination.path))
          else
            stats = @row_streamer.each_in_range(
              file_path: session.source.path,
              col_sep: session.source.separator,
              start_row: session.row_range.start_row,
              end_row: session.row_range.end_row
            ) { |fields| on_row.call(fields) if on_row }
            success(stats)
          end
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES, Errno::ENOENT => e
          if session.output_destination.file?
            failure(:cannot_write_output_file, path: session.output_destination.path, error_class: e.class)
          else
            failure(:cannot_read_file, path: session.source.path)
          end
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
