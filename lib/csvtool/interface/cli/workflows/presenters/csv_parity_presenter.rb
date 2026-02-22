# frozen_string_literal: true

require "csvtool/interface/cli/output/colorizer"
require "csvtool/interface/cli/output/table_renderer"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CsvParityPresenter
            def initialize(stdout:, colorizer: Output::Colorizer.auto(io: stdout), table_renderer: Output::TableRenderer.new, max_width: 80)
              @stdout = stdout
              @colorizer = colorizer
              @table_renderer = table_renderer
              @max_width = max_width
            end

            def print_summary(data)
              @stdout.puts(data[:match] ? @colorizer.call("MATCH", code: "32") : @colorizer.call("MISMATCH", code: "31"))
              rows = [
                ["Left rows", data[:left_rows].to_s],
                ["Right rows", data[:right_rows].to_s],
                ["Left only", data[:left_only_count].to_s],
                ["Right only", data[:right_only_count].to_s]
              ]
              @stdout.puts @table_renderer.render(headers: ["Metric", "Value"], rows: rows, max_width: @max_width)
              return if data[:match]

              print_examples("Left-only examples", data[:left_only_examples])
              print_examples("Right-only examples", data[:right_only_examples])
            end

            private

            def print_examples(label, examples)
              return if examples.nil? || examples.empty?

              @stdout.puts "#{label}:"
              examples.each do |example|
                @stdout.puts "  #{example[:row]} (count +#{example[:count_delta]})"
              end
            end
          end
        end
      end
    end
  end
end
