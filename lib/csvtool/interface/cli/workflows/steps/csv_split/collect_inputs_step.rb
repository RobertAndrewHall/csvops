# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvSplit
            class CollectInputsStep
              def initialize(file_path_prompt:, chunk_size_prompt:)
                @file_path_prompt = file_path_prompt
                @chunk_size_prompt = chunk_size_prompt
              end

              def call(context)
                context[:file_path] = @file_path_prompt.call(label: "Source CSV file path: ")
                context[:chunk_size] = Integer(@chunk_size_prompt.call)
                nil
              end
            end
          end
        end
      end
    end
  end
end
