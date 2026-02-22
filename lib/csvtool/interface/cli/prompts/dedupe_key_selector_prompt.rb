# frozen_string_literal: true

require "csvtool/domain/cross_csv_dedupe_session/column_selector"

module Csvtool
  module Interface
    module CLI
      module Prompts
        class DedupeKeySelectorPrompt
          def initialize(stdin:, stdout:)
            @stdin = stdin
            @stdout = stdout
          end

          def call(label:, headers_present:)
            if headers_present
              @stdout.print "#{label} key column name: "
            else
              @stdout.print "#{label} key column index (1-based): "
            end
            input = @stdin.gets&.strip.to_s
            Domain::CrossCsvDedupeSession::ColumnSelector.from_input(headers_present: headers_present, input: input)
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
