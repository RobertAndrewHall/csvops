# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvSplit
            class ExecuteStep
              def call(context)
                headers_result = context.fetch(:use_case).read_headers(
                  file_path: context.fetch(:file_path),
                  col_sep: ","
                )
                unless headers_result.ok?
                  context.fetch(:handle_error).call(headers_result)
                  return :halt
                end

                result = context.fetch(:use_case).call(session: context.fetch(:session))
                unless result.ok?
                  context.fetch(:handle_error).call(result)
                  return :halt
                end

                context.fetch(:presenter).print_summary(result.data.merge(chunk_size: context.fetch(:chunk_size)))
                nil
              end
            end
          end
        end
      end
    end
  end
end
