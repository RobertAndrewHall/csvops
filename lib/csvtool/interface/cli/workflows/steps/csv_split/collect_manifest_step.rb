# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvSplit
            class CollectManifestStep
              def initialize(split_manifest_prompt:)
                @split_manifest_prompt = split_manifest_prompt
              end

              def call(context)
                default_path = File.join(
                  context.fetch(:output_directory),
                  "#{context.fetch(:file_prefix)}_manifest.csv"
                )
                manifest = @split_manifest_prompt.call(default_path: default_path)
                context[:write_manifest] = manifest[:write_manifest]
                context[:manifest_path] = manifest[:manifest_path]
                nil
              end
            end
          end
        end
      end
    end
  end
end
