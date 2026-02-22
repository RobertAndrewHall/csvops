# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module RowExtraction
            class ReadHeadersStep
              def call(context)
                result = context.fetch(:use_case).read_headers(
                  file_path: context.fetch(:file_path),
                  col_sep: context.fetch(:col_sep)
                )
                unless result.ok?
                  context.fetch(:handle_error).call(result)
                  return :halt
                end

                context[:headers] = result.data[:headers]
                nil
              end
            end
          end
        end
      end
    end
  end
end
