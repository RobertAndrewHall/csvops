# frozen_string_literal: true

require "csvtool/domain/row_session/row_range"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module RowExtraction
            class CollectRangeStep
              def initialize(stdin:, stdout:)
                @stdin = stdin
                @stdout = stdout
              end

              def call(context)
                @stdout.print "Start row (1-based, inclusive): "
                start_row_input = @stdin.gets&.strip.to_s
                @stdout.print "End row (1-based, inclusive): "
                end_row_input = @stdin.gets&.strip.to_s

                context[:row_range] = Domain::RowSession::RowRange.from_inputs(
                  start_row_input: start_row_input,
                  end_row_input: end_row_input
                )
                nil
              end
            end
          end
        end
      end
    end
  end
end
