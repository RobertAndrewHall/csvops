# frozen_string_literal: true

require "csv"
require "fileutils"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/csv_splitter"
require "csvtool/infrastructure/output/csv_split_manifest_writer"

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
          csv_splitter: Infrastructure::CSV::CsvSplitter.new,
          csv_split_manifest_writer: Infrastructure::Output::CsvSplitManifestWriter.new
        )
          @header_reader = header_reader
          @csv_splitter = csv_splitter
          @csv_split_manifest_writer = csv_split_manifest_writer
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
          FileUtils.mkdir_p(output_directory)

          stats = @csv_splitter.call(
            file_path: source.path,
            col_sep: source.separator,
            headers_present: source.headers_present,
            chunk_size: session.options.chunk_size,
            output_directory: output_directory,
            file_prefix: file_prefix,
            overwrite_existing: session.options.overwrite_existing
          )
          manifest_path = maybe_write_manifest(
            session: session,
            output_directory: output_directory,
            file_prefix: file_prefix,
            stats: stats
          )
          success(stats.merge(output_directory: output_directory, file_prefix: file_prefix, manifest_path: manifest_path))
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

        def maybe_write_manifest(session:, output_directory:, file_prefix:, stats:)
          return nil unless session.options.write_manifest

          manifest_path = session.options.manifest_path || File.join(output_directory, "#{file_prefix}_manifest.csv")
          @csv_split_manifest_writer.call(
            path: manifest_path,
            chunk_paths: stats[:chunk_paths],
            chunk_row_counts: stats[:chunk_row_counts]
          )
          manifest_path
        end
      end
    end
  end
end
