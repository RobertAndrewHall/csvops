# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvSplit
            class BuildSessionStep
              def call(context)
                context[:session] = context.fetch(:session_builder).call(
                  file_path: context.fetch(:file_path),
                  col_sep: ",",
                  headers_present: true,
                  chunk_size: context.fetch(:chunk_size),
                  output_directory: context[:output_directory],
                  file_prefix: context[:file_prefix]
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
