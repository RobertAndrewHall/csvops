# frozen_string_literal: true

require "csv"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/prompts/file_path_prompt"
require "csvtool/infrastructure/csv/header_reader"

module Csvtool
  module Application
    module UseCases
      class RunRowRangeShell
        def initialize(stdin:, stdout:)
          @stdin = stdin
          @stdout = stdout
          @errors = Interface::CLI::Errors::Presenter.new(stdout: stdout)
          @header_reader = Infrastructure::CSV::HeaderReader.new
        end

        def call
          file_path = Interface::CLI::Prompts::FilePathPrompt.new(stdin: @stdin, stdout: @stdout).call
          return @errors.file_not_found(file_path) unless File.file?(file_path)

          @stdout.print "Start row (1-based, inclusive): "
          start_row = @stdin.gets&.strip.to_i
          @stdout.print "End row (1-based, inclusive): "
          end_row = @stdin.gets&.strip.to_i

          headers = @header_reader.call(file_path: file_path, col_sep: ",")
          return @errors.no_headers if headers.empty?

          @stdout.puts CSV.generate_line(headers, row_sep: "").chomp

          row_index = 0
          CSV.foreach(file_path, headers: true, col_sep: ",") do |row|
            row_index += 1
            next if row_index < start_row
            break if row_index > end_row

            @stdout.puts CSV.generate_line(row.fields, row_sep: "").chomp
          end
        rescue CSV::MalformedCSVError
          @errors.could_not_parse_csv
        rescue Errno::EACCES
          @errors.cannot_read_file(file_path)
        end
      end
    end
  end
end
