# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module RowRandomization
            class CollectInputsStep
              def initialize(file_path_prompt:, separator_prompt:, headers_present_prompt:, seed_prompt:)
                @file_path_prompt = file_path_prompt
                @separator_prompt = separator_prompt
                @headers_present_prompt = headers_present_prompt
                @seed_prompt = seed_prompt
              end

              def call(context)
                file_path = @file_path_prompt.call
                col_sep = @separator_prompt.call
                return :halt if col_sep.nil?

                headers_present = @headers_present_prompt.call
                header_result = context.fetch(:use_case).read_headers(
                  file_path: file_path,
                  col_sep: col_sep,
                  headers_present: headers_present
                )
                unless header_result.ok?
                  context.fetch(:handle_error).call(header_result)
                  return :halt
                end

                seed = @seed_prompt.call
                return :halt if seed == Interface::CLI::Prompts::SeedPrompt::INVALID

                context[:file_path] = file_path
                context[:col_sep] = col_sep
                context[:headers_present] = headers_present
                context[:headers] = header_result.data[:headers]
                context[:seed] = seed
                nil
              end
            end
          end
        end
      end
    end
  end
end
