# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module CrossCsvDedupe
            class CollectOptionsStep
              def initialize(selector_prompt:, yes_no_prompt:, output_destination_prompt:, errors:)
                @selector_prompt = selector_prompt
                @yes_no_prompt = yes_no_prompt
                @output_destination_prompt = output_destination_prompt
                @errors = errors
              end

              def call(context)
                source = context.fetch(:source)
                reference = context.fetch(:reference)

                source_selector = @selector_prompt.call(label: "Source", headers_present: source.headers_present?)
                if source_selector.nil?
                  @errors.column_not_found
                  return :halt
                end
                reference_selector = @selector_prompt.call(label: "Reference", headers_present: reference.headers_present?)
                if reference_selector.nil?
                  @errors.column_not_found
                  return :halt
                end

                trim_whitespace = @yes_no_prompt.call(label: "Trim whitespace before matching? [Y/n]: ", default: true)
                case_insensitive = @yes_no_prompt.call(label: "Case-insensitive matching? [y/N]: ", default: false)

                output_destination = @output_destination_prompt.call
                return :halt if output_destination.nil?

                context[:session] = context.fetch(:session_builder).call(
                  source: source,
                  reference: reference,
                  source_selector: source_selector,
                  reference_selector: reference_selector,
                  trim_whitespace: trim_whitespace,
                  case_insensitive: case_insensitive,
                  destination: context.fetch(:output_destination_mapper).call(output_destination)
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
