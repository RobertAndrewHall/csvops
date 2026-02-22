# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CsvStatsPresenter
            def initialize(stdout:)
              @stdout = stdout
            end

            def print_summary(data)
              @stdout.puts "CSV Stats Summary"
              @stdout.puts "Rows: #{data[:row_count]}"
              @stdout.puts "Columns: #{data[:column_count]}"
              return if data[:headers].nil? || data[:headers].empty?

              @stdout.puts "Headers: #{data[:headers].join(', ')}"
            end
          end
        end
      end
    end
  end
end
