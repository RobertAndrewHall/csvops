# frozen_string_literal: true

require "csvtool/interface/cli/output/colorizer"
require "csvtool/interface/cli/output/table_renderer"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CsvStatsPresenter
            def initialize(stdout:, colorizer: Output::Colorizer.auto(io: stdout), table_renderer: Output::TableRenderer.new, max_width: 80)
              @stdout = stdout
              @colorizer = colorizer
              @table_renderer = table_renderer
              @max_width = max_width
            end

            def print_summary(data)
              @stdout.puts @colorizer.call("CSV Stats Summary", code: "1;36")
              rows = [
                ["Rows", data[:row_count].to_s],
                ["Columns", data[:column_count].to_s]
              ]
              rows << ["Headers", data[:headers].join(", ")] unless data[:headers].nil? || data[:headers].empty?
              @stdout.puts @table_renderer.render(headers: ["Metric", "Value"], rows: rows, max_width: @max_width)
              return if data[:column_stats].nil? || data[:column_stats].empty?

              @stdout.puts
              @stdout.puts @colorizer.call("Column completeness:", code: "1")
              stat_rows = data[:column_stats].map { |stats| [stats[:name], stats[:non_blank_count].to_s, stats[:blank_count].to_s] }
              @stdout.puts @table_renderer.render(headers: ["Column", "Non-blank", "Blank"], rows: stat_rows, max_width: @max_width)
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
