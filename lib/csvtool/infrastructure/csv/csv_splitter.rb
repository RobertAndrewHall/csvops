# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module CSV
      class CsvSplitter
        class OutputFileExistsError < StandardError
          attr_reader :path

          def initialize(path)
            super("output file exists: #{path}")
            @path = path
          end
        end

        def call(file_path:, col_sep:, headers_present:, chunk_size:, output_directory:, file_prefix:, overwrite_existing:)
          ext = File.extname(file_path)
          ext = ".csv" if ext.empty?
          sequence = 0
          data_rows = 0
          chunk_paths = []
          rows_in_chunk = 0
          current_csv = nil

          write_mode_headers = nil
          write_headers = headers_present

          ::CSV.foreach(file_path, headers: headers_present, col_sep: col_sep) do |row|
            if current_csv.nil? || rows_in_chunk >= chunk_size
              current_csv&.close
              sequence += 1
              rows_in_chunk = 0
              path = File.join(output_directory, format("%<prefix>s_part_%<num>03d%<ext>s", prefix: file_prefix, num: sequence, ext: ext))
              raise OutputFileExistsError.new(path) if File.exist?(path) && !overwrite_existing

              chunk_paths << path
              write_mode_headers = headers_present ? row.headers : nil
              current_csv = ::CSV.open(path, "w", write_headers: write_headers, headers: write_mode_headers, col_sep: col_sep)
            end

            fields = headers_present ? row.fields : row
            current_csv << fields
            rows_in_chunk += 1
            data_rows += 1
          end

          {
            chunk_paths: chunk_paths,
            chunk_count: chunk_paths.length,
            data_rows: data_rows
          }
        ensure
          current_csv&.close unless current_csv&.closed?
        end
      end
    end
  end
end
