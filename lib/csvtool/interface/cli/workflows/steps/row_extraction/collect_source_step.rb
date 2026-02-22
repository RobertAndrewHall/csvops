# frozen_string_literal: true

require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module RowExtraction
            class CollectSourceStep
              def initialize(file_path_prompt:, separator_prompt:)
                @file_path_prompt = file_path_prompt
                @separator_prompt = separator_prompt
              end

              def call(context)
                context[:file_path] = @file_path_prompt.call
                col_sep = @separator_prompt.call
                return :halt if col_sep.nil?

                context[:col_sep] = col_sep
                nil
              end
            end
          end
        end
      end
    end
  end
end
