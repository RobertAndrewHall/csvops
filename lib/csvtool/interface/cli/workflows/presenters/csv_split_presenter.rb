# frozen_string_literal: true

require "csvtool/interface/cli/output/colorizer"
require "csvtool/interface/cli/output/table_renderer"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CsvSplitPresenter
            def initialize(stdout:, colorizer: Output::Colorizer.auto(io: stdout), table_renderer: Output::TableRenderer.new, max_width: 80)
              @stdout = stdout
              @colorizer = colorizer
              @table_renderer = table_renderer
              @max_width = max_width
            end

            def print_summary(data)
              @stdout.puts @colorizer.call("Split complete.", code: "1;36")
              rows = [
                ["Chunk size", data[:chunk_size].to_s],
                ["Data rows", data[:data_rows].to_s],
                ["Chunks written", data[:chunk_count].to_s]
              ]
              rows << ["Manifest", data[:manifest_path]] if data[:manifest_path]
              @stdout.puts @table_renderer.render(headers: ["Metric", "Value"], rows: rows, max_width: @max_width)
              data[:chunk_paths].each { |path| @stdout.puts path }
            end
          end
        end
      end
    end
  end
end
