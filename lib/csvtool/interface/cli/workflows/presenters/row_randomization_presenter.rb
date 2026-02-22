# frozen_string_literal: true

require "csv"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class RowRandomizationPresenter
            def initialize(stdout:, headers:, col_sep:)
              @stdout = stdout
              @headers = headers
              @col_sep = col_sep
            end

            def print_console_start
              @stdout.puts
              @stdout.puts ::CSV.generate_line(@headers, row_sep: "", col_sep: @col_sep).chomp if @headers
            end

            def print_row(fields)
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
