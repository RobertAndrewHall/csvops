# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class ColumnExtractionPresenter
            def initialize(stdout:)
              @stdout = stdout
            end

            def print_value(value)
              @stdout.puts value
            end

            def print_file_written(path)
              @stdout.puts "Wrote output to #{path}"
            end
          end
        end
      end
    end
  end
end
