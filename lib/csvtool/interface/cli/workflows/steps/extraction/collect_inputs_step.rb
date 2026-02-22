# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module Extraction
            class CollectInputsStep
              def initialize(file_path_prompt:, separator_prompt:, column_selector_prompt:, skip_blanks_prompt:)
                @file_path_prompt = file_path_prompt
                @separator_prompt = separator_prompt
                @column_selector_prompt = column_selector_prompt
                @skip_blanks_prompt = skip_blanks_prompt
              end

              def call(context)
                file_path = @file_path_prompt.call
                col_sep = @separator_prompt.call
                return :halt if col_sep.nil?

                header_result = context.fetch(:use_case).read_headers(file_path: file_path, col_sep: col_sep)
                unless header_result.ok?
                  context.fetch(:handle_error).call(header_result)
                  return :halt
                end

                headers = header_result.data[:headers]
                column_name = @column_selector_prompt.call(headers)
                return :halt if column_name.nil?

                skip_blanks = @skip_blanks_prompt.call
                context[:session] = context.fetch(:session_builder).call(
                  file_path: file_path,
                  col_sep: col_sep,
                  column_name: column_name,
                  skip_blanks: skip_blanks
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
