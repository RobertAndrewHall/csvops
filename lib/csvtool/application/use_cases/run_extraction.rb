# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/value_streamer"
require "csvtool/infrastructure/output/csv_file_writer"
require "csvtool/services/preview_builder"

module Csvtool
  module Application
    module UseCases
      class RunExtraction
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def initialize(
          header_reader: Infrastructure::CSV::HeaderReader.new,
          value_streamer: Infrastructure::CSV::ValueStreamer.new,
          preview_builder: nil,
          csv_file_writer: nil
        )
          @header_reader = header_reader
          @value_streamer = value_streamer
          @preview_builder = preview_builder || Services::PreviewBuilder.new(value_streamer: value_streamer)
          @csv_file_writer = csv_file_writer || Infrastructure::Output::CsvFileWriter.new(value_streamer: @value_streamer)
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

        def preview(session:)
          preview_values = @preview_builder.call(
            file_path: session.source.path,
            column_name: session.column_selection.name,
            col_sep: session.source.separator.value,
            skip_blanks: session.options.skip_blanks?,
            limit: session.options.preview_limit
          )
          success(preview_values: preview_values)
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES
          failure(:cannot_read_file, path: session.source.path)
        end

        def extract(session:, on_value: nil)
          if session.output_destination.file?
            @csv_file_writer.call(
              output_path: session.output_destination.path,
              file_path: session.source.path,
              column_name: session.column_selection.name,
              col_sep: session.source.separator.value,
              skip_blanks: session.options.skip_blanks?
            )
            success(output_path: session.output_destination.path)
          else
            @value_streamer.each(
              file_path: session.source.path,
              column_name: session.column_selection.name,
              col_sep: session.source.separator.value,
              skip_blanks: session.options.skip_blanks?
            ) { |value| on_value.call(value) if on_value }
            success({})
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
