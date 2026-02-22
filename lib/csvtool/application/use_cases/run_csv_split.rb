# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/csv_splitter"

module Csvtool
  module Application
    module UseCases
      class RunCsvSplit
        Result = Struct.new(:ok, :error, :data, keyword_init: true) do
          def ok?
            ok
          end
        end

        def initialize(
          header_reader: Infrastructure::CSV::HeaderReader.new,
          csv_splitter: Infrastructure::CSV::CsvSplitter.new
        )
          @header_reader = header_reader
          @csv_splitter = csv_splitter
        end

        def read_headers(file_path:, col_sep:, headers_present:)
          return failure(:file_not_found, path: file_path) unless File.file?(file_path)
          return success(headers: nil) unless headers_present

          headers = @header_reader.call(file_path: file_path, col_sep: col_sep)
          return failure(:no_headers) if headers.empty?

          success(headers: headers)
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES
          failure(:cannot_read_file, path: file_path)
        end

        def call(session:)
          source = session.source
          output_directory = session.options.output_directory || File.dirname(source.path)
          file_prefix = session.options.file_prefix || File.basename(source.path, ".*")

          stats = @csv_splitter.call(
            file_path: source.path,
            col_sep: source.separator,
            headers_present: source.headers_present,
            chunk_size: session.options.chunk_size,
            output_directory: output_directory,
            file_prefix: file_prefix,
            overwrite_existing: session.options.overwrite_existing
          )
          success(stats.merge(output_directory: output_directory, file_prefix: file_prefix))
        rescue Infrastructure::CSV::CsvSplitter::OutputFileExistsError => e
          failure(:output_file_exists, path: e.path)
        rescue CSV::MalformedCSVError
          failure(:could_not_parse_csv)
        rescue Errno::EACCES, Errno::ENOENT => e
          failure(:cannot_write_output_file, path: output_directory, error_class: e.class)
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
