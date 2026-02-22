# frozen_string_literal: true

require "csvtool/domain/row_randomization_session/randomization_source"
require "csvtool/domain/row_randomization_session/randomization_options"
require "csvtool/domain/row_randomization_session/randomization_session"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Builders
          class RowRandomizationSessionBuilder
            def call(file_path:, col_sep:, headers_present:, seed:, destination:)
              source = Domain::RowRandomizationSession::RandomizationSource.new(
                path: file_path,
                separator: col_sep,
                headers_present: headers_present
              )
              options = Domain::RowRandomizationSession::RandomizationOptions.new(seed: seed)
              session = Domain::RowRandomizationSession::RandomizationSession.start(source: source, options: options)
              session.with_output_destination(destination)
            end
          end
        end
      end
    end
  end
end
