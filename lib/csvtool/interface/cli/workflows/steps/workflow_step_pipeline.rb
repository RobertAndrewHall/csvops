# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Steps
          class WorkflowStepPipeline
            def initialize(steps:)
              @steps = steps
            end

            def call(context)
              @steps.each do |step|
                return false if step.call(context) == :halt
              end

              true
            end
          end
        end
      end
    end
  end
end
