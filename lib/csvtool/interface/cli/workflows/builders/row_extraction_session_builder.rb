# frozen_string_literal: true

require "csvtool/domain/row_session/row_source"
require "csvtool/domain/row_session/row_session"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Builders
          class RowExtractionSessionBuilder
            def call(file_path:, col_sep:, row_range:, destination:)
              source = Domain::RowSession::RowSource.new(path: file_path, separator: col_sep)
              session = Domain::RowSession::RowSession.start(source: source, row_range: row_range)
              session.with_output_destination(destination)
            end
          end
        end
      end
    end
  end
end
