# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvSplit
            class CollectInputsStep
              def initialize(file_path_prompt:, separator_prompt:, headers_present_prompt:, chunk_size_prompt:, errors:)
                @file_path_prompt = file_path_prompt
                @separator_prompt = separator_prompt
                @headers_present_prompt = headers_present_prompt
                @chunk_size_prompt = chunk_size_prompt
                @errors = errors
              end

              def call(context)
                context[:file_path] = @file_path_prompt.call(label: "Source CSV file path: ")
                col_sep = @separator_prompt.call
                return :halt if col_sep.nil?

                context[:col_sep] = col_sep
                context[:headers_present] = @headers_present_prompt.call
                chunk_size = Integer(@chunk_size_prompt.call)
                if chunk_size <= 0
                  @errors.invalid_chunk_size
                  return :halt
                end

                context[:chunk_size] = chunk_size
                nil
              rescue ArgumentError, TypeError
                @errors.invalid_chunk_size
                :halt
              end
            end
          end
        end
      end
    end
  end
end
