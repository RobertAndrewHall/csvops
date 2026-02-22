# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Errors
        class Presenter
          def initialize(stdout:)
            @stdout = stdout
          end

          def file_not_found(path)
            @stdout.puts "File not found: #{path}"
          end

          def no_headers
            @stdout.puts "No headers found."
          end

          def column_not_found
            @stdout.puts "Column not found."
          end

          def could_not_parse_csv
            @stdout.puts "Could not parse CSV file."
          end

          def cannot_read_file(path)
            @stdout.puts "Cannot read file: #{path}"
          end

          def cannot_write_output_file(path, error_class)
            @stdout.puts "Cannot write output file: #{path} (#{error_class})"
          end

          def output_file_exists(path)
            @stdout.puts "Output file already exists: #{path}"
          end

          def empty_output_path
            @stdout.puts "Output file path cannot be empty."
          end

          def invalid_output_destination
            @stdout.puts "Invalid output destination."
          end

          def empty_custom_separator
            @stdout.puts "Separator cannot be empty."
          end

          def invalid_separator_choice
            @stdout.puts "Invalid separator choice."
          end

          def invalid_seed
            @stdout.puts "Seed must be an integer."
          end

          def canceled
            @stdout.puts "Canceled."
          end

          def invalid_start_row
            @stdout.puts "Start row must be a positive integer."
          end

          def invalid_end_row
            @stdout.puts "End row must be a positive integer."
          end

          def invalid_row_range_order
            @stdout.puts "End row must be greater than or equal to start row."
          end

          def row_range_out_of_bounds(total_rows)
            @stdout.puts "Row range is out of bounds. File has #{total_rows} data rows."
          end

          def header_mismatch
            @stdout.puts "CSV headers do not match."
          end
        end
      end
    end
  end
end
