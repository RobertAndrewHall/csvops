# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CsvStats
            class CollectDestinationStep
              def initialize(output_destination_prompt:)
                @output_destination_prompt = output_destination_prompt
              end

              def call(context)
                output_destination = @output_destination_prompt.call
                return :halt if output_destination.nil?

                context[:output_destination] = context.fetch(:output_destination_mapper).call(output_destination)
                nil
              end
            end
          end
        end
      end
    end
  end
end
