# frozen_string_literal: true

require "csvtool/interface/cli/output/formatters/csv_row_formatter"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class RowExtractionPresenter
            def initialize(stdout:, headers:, col_sep:, row_formatter: Output::Formatters::CsvRowFormatter.new)
              @stdout = stdout
              @headers = headers
              @col_sep = col_sep
              @row_formatter = row_formatter
              @printed_header = false
            end

            def print_row(fields)
              unless @printed_header
                @stdout.puts @row_formatter.call(fields: @headers, col_sep: @col_sep)
                @printed_header = true
              end
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
