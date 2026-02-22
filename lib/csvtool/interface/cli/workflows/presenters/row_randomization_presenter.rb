# frozen_string_literal: true

require "csvtool/interface/cli/output/formatters/csv_row_formatter"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class RowRandomizationPresenter
            def initialize(stdout:, headers:, col_sep:, row_formatter: Output::Formatters::CsvRowFormatter.new)
              @stdout = stdout
              @headers = headers
              @col_sep = col_sep
              @row_formatter = row_formatter
            end

            def print_console_start
              @stdout.puts
              @stdout.puts @row_formatter.call(fields: @headers, col_sep: @col_sep) if @headers
            end

            def print_row(fields)
              @stdout.puts @row_formatter.call(fields: fields, col_sep: @col_sep)
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
