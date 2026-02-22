# frozen_string_literal: true

require "csvtool/domain/csv_split_session/split_source"
require "csvtool/domain/csv_split_session/split_options"
require "csvtool/domain/csv_split_session/split_session"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Builders
          class CsvSplitSessionBuilder
            def call(file_path:, col_sep:, headers_present:, chunk_size:, output_directory: nil, file_prefix: nil, overwrite_existing: false)
              source = Domain::CsvSplitSession::SplitSource.new(
                path: file_path,
                separator: col_sep,
                headers_present: headers_present
              )
              options = Domain::CsvSplitSession::SplitOptions.new(
                chunk_size: chunk_size,
                output_directory: output_directory,
                file_prefix: file_prefix,
                overwrite_existing: overwrite_existing
              )
              Domain::CsvSplitSession::SplitSession.start(source: source, options: options)
            end
          end
        end
      end
    end
  end
end
