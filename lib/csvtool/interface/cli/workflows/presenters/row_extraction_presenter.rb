# frozen_string_literal: true

require "csv"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class RowExtractionPresenter
            def initialize(stdout:, headers:, col_sep:)
              @stdout = stdout
              @headers = headers
              @col_sep = col_sep
              @printed_header = false
            end

            def print_row(fields)
              unless @printed_header
                @stdout.puts ::CSV.generate_line(@headers, row_sep: "", col_sep: @col_sep).chomp
                @printed_header = true
              end
              @stdout.puts ::CSV.generate_line(fields, row_sep: "", col_sep: @col_sep).chomp
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
