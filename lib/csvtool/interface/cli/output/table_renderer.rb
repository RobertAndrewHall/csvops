# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Output
        class TableRenderer
          MIN_COLUMN_WIDTH = 4

          def render(headers:, rows:, max_width: 80)
            widths = compute_widths(headers, rows)
            widths = fit_widths(widths, max_width)

            lines = []
            lines << format_row(headers, widths)
            lines << separator(widths)
            rows.each { |row| lines << format_row(row, widths) }
            lines.join("\n")
          end

          private

          def compute_widths(headers, rows)
            widths = headers.map { |header| header.to_s.length }
            rows.each do |row|
              row.each_with_index do |cell, index|
                widths[index] = [widths[index], cell.to_s.length].max
              end
            end
            widths
          end

          def fit_widths(widths, max_width)
            return widths if total_width(widths) <= max_width

            adjusted = widths.dup
            while total_width(adjusted) > max_width
              index = adjusted.each_with_index.max_by { |width, _i| width }[1]
              break if adjusted[index] <= MIN_COLUMN_WIDTH

              adjusted[index] -= 1
            end
            adjusted
          end

          def total_width(widths)
            widths.sum + (3 * (widths.length - 1))
          end

          def separator(widths)
            widths.map { |width| "-" * width }.join("-+-")
          end

          def format_row(row, widths)
            row.each_with_index.map do |cell, index|
              truncate(cell.to_s, widths[index]).ljust(widths[index])
            end.join(" | ")
          end

          def truncate(text, width)
            return text if text.length <= width
            return text[0, width] if width < MIN_COLUMN_WIDTH

            "#{text[0, width - 3]}..."
          end
        end
      end
    end
  end
end
