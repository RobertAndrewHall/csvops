# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module Extraction
            class ExecuteStep
              def call(context)
                result = context.fetch(:use_case).extract(
                  session: context.fetch(:session),
                  on_value: ->(value) { context.fetch(:presenter).print_value(value) }
                )
                unless result.ok?
                  context.fetch(:handle_error).call(result)
                  return :halt
                end

                session = context.fetch(:session)
                if session.output_destination.file?
                  context.fetch(:presenter).print_file_written(result.data[:output_path])
                end
                nil
              end
            end
          end
        end
      end
    end
  end
end
