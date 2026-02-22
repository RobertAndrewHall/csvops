# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvStats
            class CollectInputsStep
              def initialize(file_path_prompt:)
                @file_path_prompt = file_path_prompt
              end

              def call(context)
                context[:file_path] = @file_path_prompt.call(label: "CSV file path: ")
                context[:col_sep] = ","
                context[:headers_present] = true
                nil
              end
            end
          end
        end
      end
    end
  end
end
