# frozen_string_literal: true

require "csvtool/interface/cli/output/colorizer"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CsvStatsPresenter
            def initialize(stdout:, colorizer: Output::Colorizer.auto(io: stdout))
              @stdout = stdout
              @colorizer = colorizer
            end

            def print_summary(data)
              @stdout.puts @colorizer.call("CSV Stats Summary", code: "1;36")
              @stdout.puts "Rows: #{data[:row_count]}"
              @stdout.puts "Columns: #{data[:column_count]}"
              @stdout.puts "Headers: #{data[:headers].join(', ')}" unless data[:headers].nil? || data[:headers].empty?
              return if data[:column_stats].nil? || data[:column_stats].empty?

              @stdout.puts @colorizer.call("Column completeness:", code: "1")
              data[:column_stats].each do |stats|
                @stdout.puts "  #{stats[:name]}: non_blank=#{stats[:non_blank_count]} blank=#{stats[:blank_count]}"
              end
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
