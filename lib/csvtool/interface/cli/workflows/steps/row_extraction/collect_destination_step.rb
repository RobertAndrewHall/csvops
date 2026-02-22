# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module RowExtraction
            class CollectDestinationStep
              def initialize(output_destination_prompt:)
                @output_destination_prompt = output_destination_prompt
              end

              def call(context)
                output_destination = @output_destination_prompt.call
                return :halt if output_destination.nil?

                destination = context.fetch(:output_destination_mapper).call(output_destination)
                context[:session] = context.fetch(:session_builder).call(
                  file_path: context.fetch(:file_path),
                  col_sep: context.fetch(:col_sep),
                  row_range: context.fetch(:row_range),
                  destination: destination
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
