# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/interface/cli/prompts/separator_prompt"
require "csvtool/interface/cli/prompts/headers_present_prompt"
require "csvtool/interface/cli/prompts/seed_prompt"
require "csvtool/interface/cli/prompts/output_destination_prompt"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/row_randomizer"
require "csvtool/domain/row_randomization_session/randomization_source"
require "csvtool/domain/row_randomization_session/randomization_options"
require "csvtool/domain/row_randomization_session/randomization_session"
require "csvtool/domain/shared/output_destination"

module Csvtool
  module Application
    module UseCases
      class RunRowRandomization
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
          @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
          @header_reader = Infrastructure::CSV::HeaderReader.new
          @row_randomizer = Infrastructure::CSV::RowRandomizer.new
        end

        def call
          file_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          return @errors.file_not_found(file_path) unless File.file?(file_path)

          col_sep = Interface::CLI::Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if col_sep.nil?

          headers_present = Interface::CLI::Prompts::HeadersPresentPrompt.new(stdin: @stdin, stdout: @stdout).call
          source = Domain::RowRandomizationSession::RandomizationSource.new(
            path: file_path,
            separator: col_sep,
            headers_present: headers_present
          )
          headers = source.headers_present? ? @header_reader.call(file_path: source.path, col_sep: source.separator) : nil
          return @errors.no_headers if source.headers_present? && headers.empty?

          seed = Interface::CLI::Prompts::SeedPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if seed == Interface::CLI::Prompts::SeedPrompt::INVALID
          options = Domain::RowRandomizationSession::RandomizationOptions.new(seed: seed)
          session = Domain::RowRandomizationSession::RandomizationSession.start(source: source, options: options)

          output_destination = Interface::CLI::Prompts::OutputDestinationPrompt.new(
            stdin: @stdin,
            stdout: @stdout,
            errors: @errors
          ).call
          return if output_destination.nil?
          destination =
            if output_destination[:mode] == :file
              Domain::Shared::OutputDestination.file(path: output_destination[:path])
            else
              Domain::Shared::OutputDestination.console
            end
          session = session.with_output_destination(destination)

          randomized_rows = @row_randomizer.each(
            file_path: session.source.path,
            col_sep: session.source.separator,
            headers: session.source.headers_present?,
            seed: session.options.seed
          )

          if session.output_destination.file?
            write_output_file(session.output_destination.path, headers, randomized_rows, col_sep: session.source.separator)
          else
            print_to_console(headers, randomized_rows, col_sep: session.source.separator)
          end
        rescue CSV::MalformedCSVError
          @errors.could_not_parse_csv
        rescue ArgumentError => e
          return @errors.empty_output_path if e.message == "file output path cannot be empty"

          raise e
        rescue Errno::EACCES
          @errors.cannot_read_file(file_path)
        end

        private

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
