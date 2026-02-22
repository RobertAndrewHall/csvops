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
              @stdout.puts "Headers: #{data[:headers].join(', ')}" unless data[:headers].nil? || data[:headers].empty?
              return if data[:column_stats].nil? || data[:column_stats].empty?

              @stdout.puts "Column completeness:"
              data[:column_stats].each do |stats|
                @stdout.puts "  #{stats[:name]}: non_blank=#{stats[:non_blank_count]} blank=#{stats[:blank_count]}"
              end
            end
          end
        end
      end
    end
  end
end
