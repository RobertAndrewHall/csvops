# frozen_string_literal: true

require "csv"
require "json"
require "csvtool/interface/cli/menu_loop"
require "csvtool/interface/cli/workflows/run_extraction_workflow"
require "csvtool/interface/cli/workflows/run_row_extraction_workflow"
require "csvtool/interface/cli/workflows/run_row_randomization_workflow"
require "csvtool/interface/cli/workflows/run_cross_csv_dedupe_workflow"
require "csvtool/interface/cli/workflows/run_csv_parity_workflow"
require "csvtool/interface/cli/workflows/run_csv_split_workflow"
require "csvtool/interface/cli/workflows/run_csv_stats_workflow"
require "csvtool/interface/cli/errors/presenter"
require "csvtool/interface/cli/output/table_renderer"
require "csvtool/interface/cli/output/streams"
require "csvtool/interface/cli/output/color_policy"
require "csvtool/interface/cli/output/colorizer"
require "csvtool/interface/cli/output/formatters/stats_formatter"
require "csvtool/infrastructure/csv/header_reader"
require "csvtool/infrastructure/csv/value_streamer"
require "csvtool/infrastructure/output/console_writer"
require "csvtool/application/use_cases/run_csv_stats"
require "csvtool/domain/csv_stats_session/stats_source"
require "csvtool/domain/csv_stats_session/stats_options"
require "csvtool/domain/csv_stats_session/stats_session"
require "csvtool/domain/shared/output_destination"

module Csvtool
  class CLI
    MENU_OPTIONS = [
      "Extract column",
      "Extract rows (range)",
      "Randomize rows",
      "Dedupe using another CSV",
      "Validate parity",
      "Split CSV into chunks",
      "CSV stats summary",
      "Exit"
    ].freeze

    def self.start(argv, stdin:, stdout:, stderr:, env: ENV)
      new(argv, stdin: stdin, stdout: stdout, stderr: stderr, env: env).run
    end

    def initialize(argv, stdin:, stdout:, stderr:, env: ENV)
      @argv = argv
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @env = env
    end

    def run
      case @argv.first
      when "menu"
        run_menu_loop
      when "column"
        run_column_command
      when "stats"
        run_stats_command
      else
        print_usage
        1
      end
    end

    private

    def run_menu_loop
      streams = Interface::CLI::Output::Streams.build(data: @stdout, ui: @stderr)
      extract_column_action = -> { Interface::CLI::Workflows::RunExtractionWorkflow.new(stdin: @stdin, stdout: streams.data, stderr: streams.ui).call }
      extract_rows_action = -> { Interface::CLI::Workflows::RunRowExtractionWorkflow.new(stdin: @stdin, stdout: streams.data, stderr: streams.ui).call }
      randomize_rows_action = -> { Interface::CLI::Workflows::RunRowRandomizationWorkflow.new(stdin: @stdin, stdout: streams.data, stderr: streams.ui).call }
      dedupe_action = -> { Interface::CLI::Workflows::RunCrossCsvDedupeWorkflow.new(stdin: @stdin, stdout: streams.data, stderr: streams.ui).call }
      parity_action = -> { Interface::CLI::Workflows::RunCsvParityWorkflow.new(stdin: @stdin, stdout: streams.data, stderr: streams.ui).call }
      split_action = -> { Interface::CLI::Workflows::RunCsvSplitWorkflow.new(stdin: @stdin, stdout: streams.data, stderr: streams.ui).call }
      stats_action = -> { Interface::CLI::Workflows::RunCsvStatsWorkflow.new(stdin: @stdin, stdout: streams.data, stderr: streams.ui).call }
      Interface::CLI::MenuLoop.new(
        stdin: @stdin,
        stdout: streams.data,
        stderr: streams.ui,
        menu_options: MENU_OPTIONS,
        extract_column_action: extract_column_action,
        extract_rows_action: extract_rows_action,
        randomize_rows_action: randomize_rows_action,
        dedupe_action: dedupe_action,
        parity_action: parity_action,
        split_action: split_action,
        stats_action: stats_action
      ).run
    end

    def print_usage
      @stderr.puts "Usage:"
      @stderr.puts "  csvtool menu"
      @stderr.puts "  csvtool column <file> <column>"
      @stderr.puts "  csvtool stats <file> [--format text|json|csv] [--color auto|always|never]"
    end

    def run_column_command
      file_path = @argv[1]
      column_name = @argv[2]
      unless file_path && column_name
        print_usage
        return 1
      end

      errors = Interface::CLI::Errors::Presenter.new(stdout: @stderr)
      return errors.file_not_found(file_path) || 1 unless File.file?(file_path)

      header_reader = Infrastructure::CSV::HeaderReader.new
      headers = header_reader.call(file_path: file_path, col_sep: ",")
      return errors.no_headers || 1 if headers.empty?
      return errors.column_not_found || 1 unless headers.include?(column_name)

      value_streamer = Infrastructure::CSV::ValueStreamer.new
      writer = Infrastructure::Output::ConsoleWriter.new(stdout: @stdout, value_streamer: value_streamer)
      writer.call(file_path: file_path, column_name: column_name, col_sep: ",", skip_blanks: true)
      0
    rescue CSV::MalformedCSVError
      errors.could_not_parse_csv
      1
    rescue Errno::EACCES
      errors.cannot_read_file(file_path)
      1
    end

    def run_stats_command
      file_path, format, color_mode = parse_stats_args(@argv[1..])
      unless file_path
        print_usage
        return 1
      end

      errors = Interface::CLI::Errors::Presenter.new(stdout: @stderr)
      unless %w[text json csv].include?(format)
        @stderr.puts "Invalid format: #{format}"
        return 1
      end
      unless %w[auto always never].include?(color_mode)
        @stderr.puts "Invalid color mode: #{color_mode}"
        return 1
      end
      source = Domain::CsvStatsSession::StatsSource.new(path: file_path, separator: ",", headers_present: true)
      options = Domain::CsvStatsSession::StatsOptions.new
      destination = Domain::Shared::OutputDestination.console
      session = Domain::CsvStatsSession::StatsSession.start(source: source, options: options).with_output_destination(destination)
      result = Application::UseCases::RunCsvStats.new.call(session: session)

      unless result.ok?
        case result.error
        when :file_not_found
          errors.file_not_found(result.data[:path])
        when :could_not_parse_csv
          errors.could_not_parse_csv
        when :cannot_read_file
          errors.cannot_read_file(result.data[:path])
        else
          @stderr.puts "Unknown error."
        end
        return 1
      end

      formatter = Interface::CLI::Output::Formatters::StatsFormatter.new(
        table_renderer: Interface::CLI::Output::TableRenderer.new
      )
      output = formatter.call(data: result.data, format: format, max_width: terminal_width)
      print_stats_output(output, format: format, color_mode: color_mode)

      0
    end

    def parse_stats_args(args)
      file_path = args[0]
      format = "text"
      color_mode = "auto"
      index = 1
      while index < args.length
        arg = args[index]
        if arg.start_with?("--format=")
          format = arg.split("=", 2)[1]
        elsif arg == "--format"
          format = args[index + 1].to_s
          index += 1
        elsif arg.start_with?("--color=")
          color_mode = arg.split("=", 2)[1]
        elsif arg == "--color"
          color_mode = args[index + 1].to_s
          index += 1
        end
        index += 1
      end
      [file_path, format, color_mode]
    end

    def print_stats_output(output, format:, color_mode:)
      if format == "text"
        policy = Interface::CLI::Output::ColorPolicy.new(mode: color_mode, io: @stdout, env: @env)
        colorizer = Interface::CLI::Output::Colorizer.new(policy: policy)
        text = apply_text_color(output, colorizer: colorizer)
        @stdout.puts text
      else
        @stdout.puts output
      end
    end

    def apply_text_color(text, colorizer:)
      text.lines.map do |line|
        line = line.chomp
        case line
        when "CSV Stats Summary"
          colorizer.call(line, code: "1;36")
        when "Column completeness:"
          colorizer.call(line, code: "1")
        when /\A(Metric|Value|Column|Non-blank|Blank)(\s+\|.*)?\z/
          colorizer.call(line, code: "1")
        else
          line
        end
      end.join("\n")
    end

    def terminal_width
      columns = @env["COLUMNS"].to_i
      return columns if columns.positive?
      return @stdout.winsize[1] if @stdout.respond_to?(:winsize)

      80
    end
  end
end
