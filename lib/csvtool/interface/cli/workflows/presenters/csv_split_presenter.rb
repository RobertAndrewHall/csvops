# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CsvSplitPresenter
            def initialize(stdout:)
              @stdout = stdout
            end

            def print_summary(data)
              @stdout.puts "Split complete."
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
