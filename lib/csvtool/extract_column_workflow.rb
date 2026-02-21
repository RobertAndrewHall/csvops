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

module Csvtool
  class ExtractColumnWorkflow
    def initialize(stdin:, stdout:)
      @stdin = stdin
      @stdout = stdout
      @errors = Errors::Presenter.new(stdout: stdout)
      @header_reader = Services::HeaderReader.new
      @value_streamer = Services::ValueStreamer.new
      @preview_builder = Services::PreviewBuilder.new(value_streamer: @value_streamer)
    end

    def run
      file_path = Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
      return @errors.file_not_found(file_path) unless File.file?(file_path)

      col_sep = Prompts::SeparatorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
      return if col_sep.nil?

      headers = @header_reader.call(file_path: file_path, col_sep: col_sep)
      return @errors.no_headers if headers.empty?

      column_name = Prompts::ColumnSelectorPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call(headers)
      return if column_name.nil?

      skip_blanks = Prompts::SkipBlanksPrompt.new(stdin: @stdin, stdout: @stdout).call
      preview_values = @preview_builder.call(
        file_path: file_path,
        column_name: column_name,
        col_sep: col_sep,
        skip_blanks: skip_blanks,
        limit: 10
      )
      confirmed = Prompts::ConfirmPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call(preview_values)
      return unless confirmed

      output_destination = Prompts::OutputDestinationPrompt.new(stdin: @stdin, stdout: @stdout, errors: @errors).call
      return if output_destination.nil?

      write_output(
        output_destination,
        file_path: file_path,
        column_name: column_name,
        col_sep: col_sep,
        skip_blanks: skip_blanks
      )
    rescue CSV::MalformedCSVError
      @errors.could_not_parse_csv
    rescue Errno::EACCES
      @errors.cannot_read_file(file_path)
    end

    private

    def writer_for(output_destination)
      case output_destination[:mode]
      when :file
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
      args[:output_path] = output_destination[:path] if output_destination[:mode] == :file
      writer.call(**args)
    end
  end
end
