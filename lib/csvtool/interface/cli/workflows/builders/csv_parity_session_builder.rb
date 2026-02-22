# frozen_string_literal: true

require "csvtool/domain/csv_parity_session/source_pair"
require "csvtool/domain/csv_parity_session/parity_options"
require "csvtool/domain/csv_parity_session/parity_session"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Builders
          class CsvParitySessionBuilder
            def call(left_path:, right_path:, col_sep:, headers_present:)
              source_pair = Domain::CsvParitySession::SourcePair.new(
                left_path: left_path,
                right_path: right_path
              )
              options = Domain::CsvParitySession::ParityOptions.new(
                separator: col_sep,
                headers_present: headers_present
              )

              Domain::CsvParitySession::ParitySession.start(
                source_pair: source_pair,
                options: options
              )
            end
          end
        end
      end
    end
  end
end
