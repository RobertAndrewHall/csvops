# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/cross_csv_deduper"

module Csvtool
  module Application
    module UseCases
      class RunCrossCsvDedupe
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
          @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
          @header_reader = Infrastructure::CSV::HeaderReader.new
          @deduper = Infrastructure::CSV::CrossCsvDeduper.new
        end

        def call
          source_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          return @errors.file_not_found(source_path) unless File.file?(source_path)
          @stdout.puts "Source CSV separator:"
          source_col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if source_col_sep.nil?
          @stdout.print "Source headers present? [Y/n]: "
          source_headers_present = !%w[n no].include?(@stdin.gets&.strip.to_s.downcase)

          @stdout.print "Reference CSV file path: "
          reference_path = @stdin.gets&.strip.to_s
          return @errors.file_not_found(reference_path) unless File.file?(reference_path)
          @stdout.puts "Reference CSV separator:"
          reference_col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if reference_col_sep.nil?
          @stdout.print "Reference headers present? [Y/n]: "
          reference_headers_present = !%w[n no].include?(@stdin.gets&.strip.to_s.downcase)

          if source_headers_present
            @stdout.print "Source key column name: "
          else
            @stdout.print "Source key column index (1-based): "
          end
          source_column = @stdin.gets&.strip.to_s
          if reference_headers_present
            @stdout.print "Reference key column name: "
          else
            @stdout.print "Reference key column index (1-based): "
          end
          reference_column = @stdin.gets&.strip.to_s

          return if source_path.empty? || reference_path.empty? || source_column.empty? || reference_column.empty?

          source_selector = resolve_selector(
            column_input: source_column,
            file_path: source_path,
            col_sep: source_col_sep,
            headers_present: source_headers_present
          )
          return @errors.column_not_found if source_selector.nil?

          reference_selector = resolve_selector(
            column_input: reference_column,
            file_path: reference_path,
            col_sep: reference_col_sep,
            headers_present: reference_headers_present
          )
          return @errors.column_not_found if reference_selector.nil?

          result = @deduper.call(
            source_path: source_path,
            reference_path: reference_path,
            source_selector: source_selector,
            reference_selector: reference_selector,
            source_col_sep: source_col_sep,
            reference_col_sep: reference_col_sep,
            source_has_headers: source_headers_present,
            reference_has_headers: reference_headers_present
          )

          output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
            stdin: @stdin,
            stdout: @stdout,
            errors: @errors
          ).call
          return if output_destination.nil?

          if output_destination[:mode] == :file
            write_output_file(output_destination[:path], result[:headers], result[:kept_rows], col_sep: source_col_sep)
          else
            print_to_console(result[:headers], result[:kept_rows], col_sep: source_col_sep)
          end
          @stdout.puts "Summary: source_rows=#{result[:source_rows]} removed_rows=#{result[:removed_rows]} kept_rows=#{result[:kept_rows_count]}"
        rescue CSV::MalformedCSVError
          @errors.could_not_parse_csv
        rescue Errno::EACCES
          @errors.cannot_read_file(source_path)
        end

        private

        def resolve_selector(column_input:, file_path:, col_sep:, headers_present:)
          if headers_present
            headers = @header_reader.call(file_path: file_path, col_sep: col_sep)
            return nil if headers.empty?
            return column_input if headers.include?(column_input)

            nil
          else
            return nil unless /\A[1-9]\d*\z/.match?(column_input)

            index = column_input.to_i
            first_row = ::CSV.open(file_path, "r", headers: false, col_sep: col_sep, &:first)
            return nil if first_row.nil?
            return nil if index > first_row.length

            index
          end
        end

        def print_to_console(headers, rows, col_sep:)
          @stdout.puts
          @stdout.puts ::CSV.generate_line(headers, row_sep: "", col_sep: col_sep).chomp if headers
          rows.each { |fields| @stdout.puts ::CSV.generate_line(fields, row_sep: "", col_sep: col_sep).chomp }
        end

        def write_output_file(path, headers, rows, col_sep:)
          ::CSV.open(path, "w", write_headers: !headers.nil?, headers: headers, col_sep: col_sep) do |csv|
            rows.each { |fields| csv << fields }
          end
          @stdout.puts "Wrote output to #{path}"
        rescue Errno::EACCES, Errno::ENOENT => e
          @errors.cannot_write_output_file(path, e.class)
        end
      end
    end
  end
end
