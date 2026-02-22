# frozen_string_literal: true

require "csvtool/interface/cli/output/colorizer"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CsvSplitPresenter
            def initialize(stdout:, colorizer: Output::Colorizer.auto(io: stdout))
              @stdout = stdout
              @colorizer = colorizer
            end

            def print_summary(data)
              @stdout.puts @colorizer.call("Split complete.", code: "1;36")
              @stdout.puts "Chunk size: #{data[:chunk_size]}"
              @stdout.puts "Data rows: #{data[:data_rows]}"
              @stdout.puts "Chunks written: #{data[:chunk_count]}"
              @stdout.puts "Manifest: #{data[:manifest_path]}" if data[:manifest_path]
              data[:chunk_paths].each { |path| @stdout.puts path }
            end
          end
        end
      end
    end
  end
end
