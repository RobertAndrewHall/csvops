# frozen_string_literal: true

require "csv"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CrossCsvDedupePresenter
            def initialize(stdout:, col_sep:)
              @stdout = stdout
              @col_sep = col_sep
            end

            def print_header(headers)
              @stdout.puts
              @stdout.puts ::CSV.generate_line(headers, row_sep: "", col_sep: @col_sep).chomp
            end

            def print_row(fields)
              @stdout.puts ::CSV.generate_line(fields, row_sep: "", col_sep: @col_sep).chomp
            end

            def print_file_written(path)
              @stdout.puts "Wrote output to #{path}"
            end

            def print_summary(stats)
              @stdout.puts "Summary: source_rows=#{stats[:source_rows]} removed_rows=#{stats[:removed_rows]} kept_rows=#{stats[:kept_rows_count]}"
              @stdout.puts "No rows removed; no matching keys found." if stats[:removed_rows].zero?
              @stdout.puts "All source rows were removed by dedupe." if stats[:source_rows].positive? && stats[:kept_rows_count].zero?
            end
          end
        end
      end
    end
  end
end
