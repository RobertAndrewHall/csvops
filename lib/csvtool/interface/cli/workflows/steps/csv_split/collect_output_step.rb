# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvSplit
            class CollectOutputStep
              def initialize(split_output_prompt:)
                @split_output_prompt = split_output_prompt
              end

              def call(context)
                file_path = context.fetch(:file_path)
                output = @split_output_prompt.call(
                  default_directory: File.dirname(file_path),
                  default_prefix: File.basename(file_path, ".*")
                )
                context[:output_directory] = output[:output_directory]
                context[:file_prefix] = output[:file_prefix]
                context[:overwrite_existing] = output[:overwrite_existing]
                nil
              end
            end
          end
        end
      end
    end
  end
end
