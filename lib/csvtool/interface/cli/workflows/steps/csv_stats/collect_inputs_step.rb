# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvStats
            class CollectInputsStep
              def initialize(file_path_prompt:, separator_prompt:, headers_present_prompt:)
                @file_path_prompt = file_path_prompt
                @separator_prompt = separator_prompt
                @headers_present_prompt = headers_present_prompt
              end

              def call(context)
                context[:file_path] = @file_path_prompt.call(label: "CSV file path: ")
                col_sep = @separator_prompt.call
                return :halt if col_sep.nil?

                context[:col_sep] = col_sep
                context[:headers_present] = @headers_present_prompt.call
                nil
              end
            end
          end
        end
      end
    end
  end
end
