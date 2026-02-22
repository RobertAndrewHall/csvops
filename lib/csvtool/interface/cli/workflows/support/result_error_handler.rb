# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Support
          class ResultErrorHandler
            def initialize(errors:)
              @errors = errors
            end

            def call(result, mapping)
              action = mapping[result.error]
              action&.call(result, @errors)
            end
          end
        end
      end
    end
  end
end
