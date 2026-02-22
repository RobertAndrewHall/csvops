# frozen_string_literal: true

require "csv"
require "csvtool/application/use_cases/run_cross_csv_dedupe"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/prompts/yes_no_prompt"
require "csvtool/interface/cli/prompts/dedupe_key_selector_prompt"
require "csvtool/interface/cli/workflows/builders/cross_csv_dedupe_session_builder"
require "csvtool/interface/cli/workflows/support/output_destination_mapper"
require "csvtool/interface/cli/workflows/support/result_error_handler"
require "csvtool/domain/cross_csv_dedupe_session/csv_profile"
require "csvtool/domain/cross_csv_dedupe_session/column_selector"
module Csvtool
  module Interface
    module CLI
      module Workflows
        class RunCrossCsvDedupeWorkflow
          def initialize(stdin:, stdout:, use_case: Application::UseCases::RunCrossCsvDedupe.new)
            @stdin = stdin
            @stdout = stdout
            @use_case = use_case
            @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
            @session_builder = Builders::CrossCsvDedupeSessionBuilder.new
            @output_destination_mapper = Support::OutputDestinationMapper.new
            @result_error_handler = Support::ResultErrorHandler.new(errors: @errors)
          end

          def call
            source_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
            return @errors.file_not_found(source_path) unless File.file?(source_path)

            @stdout.puts "Source CSV separator:"
            source_col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
            return if source_col_sep.nil?
            source_headers_present = Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: @stdin, stdout: @stdout)
              .call(label: "Source headers present? [Y/n]: ")
            source = Domain::CrossCsvDedupeSession::CsvProfile.new(
              path: source_path,
              separator: source_col_sep,
              headers_present: source_headers_present
            )

            @stdout.print "Reference CSV file path: "
            reference_path = @stdin.gets&.strip.to_s
            return @errors.file_not_found(reference_path) unless File.file?(reference_path)

            @stdout.puts "Reference CSV separator:"
            reference_col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
            return if reference_col_sep.nil?
            reference_headers_present = Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: @stdin, stdout: @stdout)
              .call(label: "Reference headers present? [Y/n]: ")
            reference = Domain::CrossCsvDedupeSession::CsvProfile.new(
              path: reference_path,
              separator: reference_col_sep,
              headers_present: reference_headers_present
            )

            selector_prompt = Interface::CLI::Prompts::DedupeKeySelectorPrompt.new(stdin: @stdin, stdout: @stdout)
            source_selector = selector_prompt.call(label: "Source", headers_present: source.headers_present?)
            return @errors.column_not_found if source_selector.nil?
            reference_selector = selector_prompt.call(label: "Reference", headers_present: reference.headers_present?)
            return @errors.column_not_found if reference_selector.nil?

            yes_no_prompt = Interface::CLI::Prompts::YesNoPrompt.new(stdin: @stdin, stdout: @stdout)
            trim_whitespace = yes_no_prompt.call(label: "Trim whitespace before matching? [Y/n]: ", default: true)
            case_insensitive = yes_no_prompt.call(label: "Case-insensitive matching? [y/N]: ", default: false)

            output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
              stdin: @stdin,
              stdout: @stdout,
              errors: @errors
            ).call
            return if output_destination.nil?

            session = @session_builder.call(
              source: source,
              reference: reference,
              source_selector: source_selector,
              reference_selector: reference_selector,
              trim_whitespace: trim_whitespace,
              case_insensitive: case_insensitive,
              destination: @output_destination_mapper.call(output_destination)
            )

            result = @use_case.call(
              session: session,
              on_header: ->(headers) { print_header(headers, col_sep: session.source.separator) },
              on_row: ->(fields) { print_row(fields, col_sep: session.source.separator) }
            )
            return handle_error(result) unless result.ok?

            @stdout.puts "Wrote output to #{result.data[:output_path]}" if session.output_destination.file?
            stats = result.data[:stats]
            @stdout.puts "Summary: source_rows=#{stats[:source_rows]} removed_rows=#{stats[:removed_rows]} kept_rows=#{stats[:kept_rows_count]}"
            @stdout.puts "No rows removed; no matching keys found." if stats[:removed_rows].zero?
            @stdout.puts "All source rows were removed by dedupe." if stats[:source_rows].positive? && stats[:kept_rows_count].zero?
          rescue ArgumentError => e
            return @errors.empty_output_path if e.message == "file output path cannot be empty"

            raise e
          end

          private

          def print_header(headers, col_sep:)
            @stdout.puts
            @stdout.puts ::CSV.generate_line(headers, row_sep: "", col_sep: col_sep).chomp
          end

          def print_row(fields, col_sep:)
            @stdout.puts ::CSV.generate_line(fields, row_sep: "", col_sep: col_sep).chomp
          end

          def handle_error(result)
            @result_error_handler.call(result, {
              column_not_found: ->(_r, errors) { errors.column_not_found },
              could_not_parse_csv: ->(_r, errors) { errors.could_not_parse_csv },
              cannot_read_file: ->(r, errors) { errors.cannot_read_file(r.data[:path]) },
              cannot_write_output_file: ->(r, errors) { errors.cannot_write_output_file(r.data[:path], r.data[:error_class]) }
            })
          end

        end
      end
    end
  end
end
