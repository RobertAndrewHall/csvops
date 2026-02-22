# frozen_string_literal: true

require "json"

module Csvtool
  module Interface
    module CLI
      module Output
        module Formatters
          class StatsFormatter
            def initialize(table_renderer:)
              @table_renderer = table_renderer
            end

            def call(data:, format:, max_width: 80)
              case format
              when "json"
                JSON.generate(data)
              when "csv"
                csv_lines(data).join("\n")
              else
                text_lines(data, max_width: max_width).join("\n")
              end
            end

            private

            def csv_lines(data)
              lines = ["metric,value", "row_count,#{data[:row_count]}", "column_count,#{data[:column_count]}"]
              lines << "headers,#{data[:headers].join('|')}" unless data[:headers].nil? || data[:headers].empty?
              data.fetch(:column_stats, []).each do |stats|
                lines << "column.#{stats[:name]}.non_blank,#{stats[:non_blank_count]}"
                lines << "column.#{stats[:name]}.blank,#{stats[:blank_count]}"
              end
              lines
            end

            def text_lines(data, max_width:)
              lines = ["CSV Stats Summary"]
              summary_rows = [["Rows", data[:row_count].to_s], ["Columns", data[:column_count].to_s]]
              summary_rows << ["Headers", data[:headers].join(", ")] unless data[:headers].nil? || data[:headers].empty?
              lines << @table_renderer.render(headers: ["Metric", "Value"], rows: summary_rows, max_width: max_width)

              return lines if data[:column_stats].nil? || data[:column_stats].empty?

              lines << ""
              lines << "Column completeness:"
              rows = data[:column_stats].map { |stats| [stats[:name], stats[:non_blank_count].to_s, stats[:blank_count].to_s] }
              lines << @table_renderer.render(headers: ["Column", "Non-blank", "Blank"], rows: rows, max_width: max_width)
              lines
            end
          end
        end
      end
    end
  end
end
