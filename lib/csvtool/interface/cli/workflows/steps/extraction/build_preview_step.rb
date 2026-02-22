# frozen_string_literal: true

require "csvtool/domain/column_session/extraction_value"
require "csvtool/domain/column_session/preview"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          module Extraction
            class BuildPreviewStep
              def initialize(confirm_prompt:)
                @confirm_prompt = confirm_prompt
              end

              def call(context)
                preview_result = context.fetch(:use_case).preview(session: context.fetch(:session))
                unless preview_result.ok?
                  context.fetch(:handle_error).call(preview_result)
                  return :halt
                end

                preview = Domain::ColumnSession::Preview.new(
                  values: preview_result.data[:preview_values].map { |value| Domain::ColumnSession::ExtractionValue.new(value) }
                )
                session = context.fetch(:session).with_preview(preview)
                confirmed = @confirm_prompt.call(session.preview.to_strings)
                return :halt unless confirmed

                context[:session] = session.confirm!
                nil
              end
            end
          end
        end
      end
    end
  end
end
