# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module Parity
            class ExecuteStep
              def call(context)
                result = context.fetch(:use_case).call(session: context.fetch(:session))
                unless result.ok?
                  context.fetch(:handle_error).call(result)
                  return :halt
                end

                context.fetch(:presenter).print_summary(result.data)
                nil
              end
            end
          end
        end
      end
    end
  end
end
