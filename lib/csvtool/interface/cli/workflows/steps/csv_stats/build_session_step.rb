# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvStats
            class BuildSessionStep
              def call(context)
                context[:session] = context.fetch(:session_builder).call(
                  file_path: context.fetch(:file_path),
                  col_sep: context.fetch(:col_sep),
                  headers_present: context.fetch(:headers_present)
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
