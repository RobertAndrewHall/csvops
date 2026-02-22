# frozen_string_literal: true

require "csvtool/domain/shared/output_destination"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Support
          class OutputDestinationMapper
            def call(output_destination)
              if output_destination[:mode] == :file
                Domain::Shared::OutputDestination.file(path: output_destination[:path])
              else
                Domain::Shared::OutputDestination.console
              end
            end
          end
        end
      end
    end
  end
end
