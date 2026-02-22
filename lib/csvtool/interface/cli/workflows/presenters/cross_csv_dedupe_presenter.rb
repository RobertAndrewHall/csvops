# frozen_string_literal: true

require "csvtool/interface/cli/output/formatters/csv_row_formatter"
require "csvtool/interface/cli/output/colorizer"
require "csvtool/interface/cli/output/table_renderer"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CrossCsvDedupePresenter
            def initialize(stdout:, col_sep:, row_formatter: Output::Formatters::CsvRowFormatter.new, colorizer: Output::Colorizer.auto(io: stdout), table_renderer: Output::TableRenderer.new, max_width: 80)
              @stdout = stdout
              @col_sep = col_sep
              @row_formatter = row_formatter
              @colorizer = colorizer
              @table_renderer = table_renderer
              @max_width = max_width
            end

            def print_header(headers)
              @stdout.puts
              @stdout.puts @row_formatter.call(fields: headers, col_sep: @col_sep)
            end

            def print_row(fields)
              @stdout.puts @row_formatter.call(fields: fields, col_sep: @col_sep)
            end

            def print_file_written(path)
              @stdout.puts "Wrote output to #{path}"
            end

            def print_summary(stats)
              rows = [
                ["Source rows", stats[:source_rows].to_s],
                ["Removed rows", stats[:removed_rows].to_s],
                ["Kept rows", stats[:kept_rows_count].to_s]
              ]
              @stdout.puts @colorizer.call("Summary", code: "1")
              @stdout.puts @table_renderer.render(headers: ["Metric", "Value"], rows: rows, max_width: @max_width)
              @stdout.puts "No rows removed; no matching keys found." if stats[:removed_rows].zero?
              @stdout.puts "All source rows were removed by dedupe." if stats[:source_rows].positive? && stats[:kept_rows_count].zero?
            end
          end
        end
      end
    end
  end
end
