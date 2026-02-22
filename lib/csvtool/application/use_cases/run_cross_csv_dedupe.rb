# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/cross_csv_deduper"
require "csvtool/infrastructure/csv/selector_validator"
require "csvtool/infrastructure/output/csv_cross_csv_dedupe_file_writer"

module Csvtool
  module Application
    module UseCases
      class RunCrossCsvDedupe
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def initialize(
          header_reader: Infrastructure::CSV::HeaderReader.new,
          deduper: Infrastructure::CSV::CrossCsvDeduper.new,
          selector_validator: Infrastructure::CSV::SelectorValidator.new(header_reader: header_reader),
          csv_cross_csv_dedupe_file_writer: nil
        )
          @header_reader = header_reader
          @deduper = deduper
          @selector_validator = selector_validator
          @csv_cross_csv_dedupe_file_writer = csv_cross_csv_dedupe_file_writer || Infrastructure::Output::CsvCrossCsvDedupeFileWriter.new(
            deduper: @deduper
          )
        end

        def call(session:, on_header: nil, on_row: nil)
          current_read_path = session.source.path
          return failure(:column_not_found) unless @selector_validator.valid?(profile: session.source, selector: session.key_mapping.source_selector)

          current_read_path = session.reference.path
          return failure(:column_not_found) unless @selector_validator.valid?(profile: session.reference, selector: session.key_mapping.reference_selector)

          source_headers = session.source.headers_present? ? @header_reader.call(file_path: session.source.path, col_sep: session.source.separator) : nil
          current_read_path = session.source.path

          if session.output_destination.file?
            write_file(session: session, source_headers: source_headers)
          else
            on_header.call(source_headers) if on_header && source_headers
            stats = @deduper.each_retained(**dedupe_options(session)) do |fields|
              on_row.call(fields) if on_row
            end
            success(stats: stats)
          end
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES, Errno::ENOENT => e
          if session.output_destination.file?
            failure(:cannot_write_output_file, path: session.output_destination.path, error_class: e.class)
          else
            failure(:cannot_read_file, path: current_read_path || session.source.path)
          end
        end

        private

        def write_file(session:, source_headers:)
          stats = @csv_cross_csv_dedupe_file_writer.call(
            path: session.output_destination.path,
            headers: source_headers,
            col_sep: session.source.separator,
            dedupe_options: dedupe_options(session)
          )
          success(stats: stats, output_path: session.output_destination.path)
        end

        def dedupe_options(session)
          {
            source_path: session.source.path,
            reference_path: session.reference.path,
            source_selector: session.key_mapping.source_selector,
            reference_selector: session.key_mapping.reference_selector,
            source_col_sep: session.source.separator,
            reference_col_sep: session.reference.separator,
            match_options: session.match_options
          }
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
