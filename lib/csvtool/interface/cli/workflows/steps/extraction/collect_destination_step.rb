# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module Extraction
            class CollectDestinationStep
              def initialize(output_destination_prompt:)
                @output_destination_prompt = output_destination_prompt
              end

              def call(context)
                output_destination = @output_destination_prompt.call
                return :halt if output_destination.nil?

                destination = context.fetch(:output_destination_mapper).call(output_destination)
                context[:session] = context.fetch(:session).with_output_destination(destination)
                nil
              end
            end
          end
        end
      end
    end
  end
end
