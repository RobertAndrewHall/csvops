# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/cross_csv_deduper"
require "csvtool/domain/cross_csv_dedupe_session/csv_profile"
require "csvtool/domain/cross_csv_dedupe_session/column_selector"
require "csvtool/domain/cross_csv_dedupe_session/key_mapping"
require "csvtool/domain/cross_csv_dedupe_session/match_options"
require "csvtool/domain/cross_csv_dedupe_session/output_destination"
require "csvtool/domain/cross_csv_dedupe_session/cross_csv_dedupe_session"

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
          current_read_path = source_path
          @stdout.puts "Source CSV separator:"
          source_col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if source_col_sep.nil?
          @stdout.print "Source headers present? [Y/n]: "
          source_headers_present = !%w[n no].include?(@stdin.gets&.strip.to_s.downcase)
          source = Domain::CrossCsvDedupeSession::CsvProfile.new(
            path: source_path,
            separator: source_col_sep,
            headers_present: source_headers_present
          )

          @stdout.print "Reference CSV file path: "
          reference_path = @stdin.gets&.strip.to_s
          return @errors.file_not_found(reference_path) unless File.file?(reference_path)
          current_read_path = reference_path
          @stdout.puts "Reference CSV separator:"
          reference_col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if reference_col_sep.nil?
          @stdout.print "Reference headers present? [Y/n]: "
          reference_headers_present = !%w[n no].include?(@stdin.gets&.strip.to_s.downcase)
          reference = Domain::CrossCsvDedupeSession::CsvProfile.new(
            path: reference_path,
            separator: reference_col_sep,
            headers_present: reference_headers_present
          )

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
          @stdout.print "Trim whitespace before matching? [Y/n]: "
          trim_whitespace = read_yes_no(default: true)
          @stdout.print "Case-insensitive matching? [y/N]: "
          case_insensitive = read_yes_no(default: false)

          return if source_path.empty? || reference_path.empty? || source_column.empty? || reference_column.empty?

          source_selector = resolve_selector(
            column_input: source_column,
            profile: source
          )
          return @errors.column_not_found if source_selector.nil?

          reference_selector = resolve_selector(
            column_input: reference_column,
            profile: reference
          )
          return @errors.column_not_found if reference_selector.nil?
          key_mapping = Domain::CrossCsvDedupeSession::KeyMapping.new(
            source_selector: source_selector,
            reference_selector: reference_selector
          )
          match_options = Domain::CrossCsvDedupeSession::MatchOptions.new(
            trim_whitespace: trim_whitespace,
            case_insensitive: case_insensitive
          )
          session = Domain::CrossCsvDedupeSession::CrossCsvDedupeSession.start(
            source: source,
            reference: reference,
            key_mapping: key_mapping,
            match_options: match_options
          )

          output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
            stdin: @stdin,
            stdout: @stdout,
            errors: @errors
          ).call
          return if output_destination.nil?
          destination =
            if output_destination[:mode] == :file
              Domain::CrossCsvDedupeSession::OutputDestination.file(path: output_destination[:path])
            else
              Domain::CrossCsvDedupeSession::OutputDestination.console
            end
          session = session.with_output_destination(destination)

          source_headers = session.source.headers_present? ? @header_reader.call(file_path: session.source.path, col_sep: session.source.separator) : nil
          dedupe_options = {
            source_path: session.source.path,
            reference_path: session.reference.path,
            source_selector: session.key_mapping.source_selector.value,
            reference_selector: session.key_mapping.reference_selector.value,
            source_col_sep: session.source.separator,
            reference_col_sep: session.reference.separator,
            source_has_headers: session.source.headers_present?,
            reference_has_headers: session.reference.headers_present?,
            trim_whitespace: session.match_options.trim_whitespace?,
            case_insensitive: session.match_options.case_insensitive?
          }

          current_read_path = session.source.path
          if session.output_destination.file?
            result = write_output_file(
              session.output_destination.path,
              source_headers,
              col_sep: session.source.separator,
              dedupe_options: dedupe_options
            )
            return if result.nil?
          else
            result = print_to_console(
              source_headers,
              col_sep: session.source.separator,
              dedupe_options: dedupe_options
            )
          end
          @stdout.puts "Summary: source_rows=#{result[:source_rows]} removed_rows=#{result[:removed_rows]} kept_rows=#{result[:kept_rows_count]}"
          @stdout.puts "No rows removed; no matching keys found." if result[:removed_rows].zero?
          @stdout.puts "All source rows were removed by dedupe." if result[:source_rows].positive? && result[:kept_rows_count].zero?
        rescue CSV::MalformedCSVError
          @errors.could_not_parse_csv
        rescue ArgumentError => e
          return @errors.empty_output_path if e.message == "file output path cannot be empty"

          raise e
        rescue Errno::EACCES
          @errors.cannot_read_file(current_read_path || source_path)
        end

        private

        def resolve_selector(column_input:, profile:)
          selector = Domain::CrossCsvDedupeSession::ColumnSelector.from_input(
            headers_present: profile.headers_present?,
            input: column_input
          )

          if selector.headers_present?
            headers = @header_reader.call(file_path: profile.path, col_sep: profile.separator)
            return nil if headers.empty?
            return selector if headers.include?(selector.value)

            nil
          else
            first_row = ::CSV.open(profile.path, "r", headers: false, col_sep: profile.separator, &:first)
            return nil if first_row.nil?
            return nil if selector.value > first_row.length

            selector
          end
        rescue ArgumentError
          nil
        end

        def print_to_console(headers, col_sep:, dedupe_options:)
          @stdout.puts
          @stdout.puts ::CSV.generate_line(headers, row_sep: "", col_sep: col_sep).chomp if headers
          @deduper.each_retained(**dedupe_options) do |fields|
            @stdout.puts ::CSV.generate_line(fields, row_sep: "", col_sep: col_sep).chomp
          end
        end

        def write_output_file(path, headers, col_sep:, dedupe_options:)
          result = nil
          ::CSV.open(path, "w", write_headers: !headers.nil?, headers: headers, col_sep: col_sep) do |csv|
            result = @deduper.each_retained(**dedupe_options) { |fields| csv << fields }
          end
          @stdout.puts "Wrote output to #{path}"
          result
        rescue Errno::EACCES, Errno::ENOENT => e
          @errors.cannot_write_output_file(path, e.class)
          nil
        end

        def read_yes_no(default:)
          answer = @stdin.gets&.strip.to_s.downcase
          return default if answer.empty?
          return true if %w[y yes].include?(answer)
          return false if %w[n no].include?(answer)

          default
        end
      end
    end
  end
end
