# frozen_string_literal: true

require "csvtool/domain/column_session/separator"
require "csvtool/domain/column_session/csv_source"
require "csvtool/domain/column_session/column_selection"
require "csvtool/domain/column_session/extraction_options"
require "csvtool/domain/column_session/column_session"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Builders
          class ColumnSessionBuilder
            def call(file_path:, col_sep:, column_name:, skip_blanks:)
              separator = Domain::ColumnSession::Separator.new(col_sep)
              source = Domain::ColumnSession::CsvSource.new(path: file_path, separator: separator)
              column_selection = Domain::ColumnSession::ColumnSelection.new(name: column_name)
              options = Domain::ColumnSession::ExtractionOptions.new(skip_blanks: skip_blanks, preview_limit: 10)

              Domain::ColumnSession::ColumnSession.start(
                source: source,
                column_selection: column_selection,
                options: options
              )
            end
          end
        end
      end
    end
  end
end
