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
                  col_sep: context.fetch(:col_sep),
                  headers_present: context.fetch(:headers_present),
                  chunk_size: context.fetch(:chunk_size),
                  output_directory: context[:output_directory],
                  file_prefix: context[:file_prefix],
                  overwrite_existing: context.fetch(:overwrite_existing, false)
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
