# frozen_string_literal: true

require "csv"
require "csvtool/errors/presenter"
require "csvtool/prompts/file_path_prompt"
require "csvtool/prompts/separator_prompt"
require "csvtool/prompts/column_selector_prompt"
require "csvtool/prompts/skip_blanks_prompt"
require "csvtool/prompts/confirm_prompt"
require "csvtool/prompts/output_destination_prompt"
require "csvtool/services/header_reader"
require "csvtool/services/value_streamer"
require "csvtool/services/preview_builder"
require "csvtool/output/console_writer"
require "csvtool/output/csv_file_writer"
require "csvtool/domain/extraction_session/separator"
require "csvtool/domain/extraction_session/csv_source"
require "csvtool/domain/extraction_session/column_selection"
require "csvtool/domain/extraction_session/extraction_options"
require "csvtool/domain/extraction_session/extraction_value"
require "csvtool/domain/extraction_session/preview"
require "csvtool/domain/extraction_session/output_destination"
require "csvtool/domain/extraction_session/extraction_session"

module Csvtool
  module Application
    module UseCases
      class RunExtraction
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
          @errors = Errors::Presenter.new(stdout: stdout)
          @header_reader = Services::HeaderReader.new
          @value_streamer = Services::ValueStreamer.new
          @preview_builder = Services::PreviewBuilder.new(value_streamer: @value_streamer)
        end

        def call
          file_path = Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          return @errors.file_not_found(file_path) unless File.file?(file_path)

          col_sep = Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if col_sep.nil?
          separator = Domain::ExtractionSession::Separator.new(col_sep)

          source = Domain::ExtractionSession::CsvSource.new(path: file_path, separator: separator)
          headers = @header_reader.call(file_path: source.path, col_sep: source.separator.value)
          return @errors.no_headers if headers.empty?

          column_name = Prompts::ColumnSelectorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call(headers)
          return if column_name.nil?
          column_selection = Domain::ExtractionSession::ColumnSelection.new(name: column_name)

          skip_blanks = Prompts::SkipBlanksPrompt.new(stdin: @stdin, stdout: @stdout).call
          options = Domain::ExtractionSession::ExtractionOptions.new(skip_blanks: skip_blanks, preview_limit: 10)
          session = Domain::ExtractionSession::ExtractionSession.start(
            source: source,
            column_selection: column_selection,
            options: options
          )

          preview_values = @preview_builder.call(
            file_path: session.source.path,
            column_name: session.column_selection.name,
            col_sep: session.source.separator.value,
            skip_blanks: session.options.skip_blanks?,
            limit: session.options.preview_limit
          )
          preview = Domain::ExtractionSession::Preview.new(
            values: preview_values.map { |value| Domain::ExtractionSession::ExtractionValue.new(value) }
          )
          session = session.with_preview(preview)

          confirmed = Prompts::ConfirmPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call(session.preview.to_strings)
          return unless confirmed
          session = session.confirm!

          output_destination = Prompts::OutputDestinationPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
          return if output_destination.nil?
          domain_destination =
            if output_destination[:mode] == :file
              Domain::ExtractionSession::OutputDestination.file(path: output_destination[:path])
            else
              Domain::ExtractionSession::OutputDestination.console
            end
          session = session.with_output_destination(domain_destination)

          write_output(
            session.output_destination,
            file_path: session.source.path,
            column_name: session.column_selection.name,
            col_sep: session.source.separator.value,
            skip_blanks: session.options.skip_blanks?
          )
        rescue CSV::MalformedCSVError
          @errors.could_not_parse_csv
        rescue Errno::EACCES
          @errors.cannot_read_file(file_path)
        end

        private

        def writer_for(output_destination)
          if output_destination.file?
            Output::CsvFileWriter.new(stdout: @stdout, errors: @errors, value_streamer: @value_streamer)
          else
            Output::ConsoleWriter.new(stdout: @stdout, value_streamer: @value_streamer)
          end
        end

        def write_output(output_destination, file_path:, column_name:, col_sep:, skip_blanks:)
          writer = writer_for(output_destination)
          args = {
            file_path: file_path,
            column_name: column_name,
            col_sep: col_sep,
            skip_blanks: skip_blanks
          }
          args[:output_path] = output_destination.path if output_destination.file?
          writer.call(**args)
        end
      end
    end
  end
end
