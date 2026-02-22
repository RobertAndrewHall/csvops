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

      print_stats(result.data, format: format, color_mode: color_mode)

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

    def print_stats(data, format:, color_mode:)
      case format
      when "json"
        @stdout.puts JSON.generate(data)
      when "csv"
        @stdout.puts "metric,value"
        @stdout.puts "row_count,#{data[:row_count]}"
        @stdout.puts "column_count,#{data[:column_count]}"
        @stdout.puts "headers,#{data[:headers].join('|')}" unless data[:headers].nil? || data[:headers].empty?
        data.fetch(:column_stats, []).each do |stats|
          @stdout.puts "column.#{stats[:name]}.non_blank,#{stats[:non_blank_count]}"
          @stdout.puts "column.#{stats[:name]}.blank,#{stats[:blank_count]}"
        end
      else
        use_color = color_enabled?(color_mode)
        table_renderer = Interface::CLI::Output::TableRenderer.new
        max_width = terminal_width
        @stdout.puts colorize("CSV Stats Summary", code: "1;36", enabled: use_color)
        summary_rows = [
          ["Rows", data[:row_count].to_s],
          ["Columns", data[:column_count].to_s]
        ]
        summary_rows << ["Headers", data[:headers].join(", ")] unless data[:headers].nil? || data[:headers].empty?
        @stdout.puts table_renderer.render(headers: ["Metric", "Value"], rows: summary_rows, max_width: max_width)
        if data[:column_stats] && !data[:column_stats].empty?
          @stdout.puts
          @stdout.puts colorize("Column completeness:", code: "1", enabled: use_color)
          rows = data[:column_stats].map do |stats|
            [stats[:name], stats[:non_blank_count].to_s, stats[:blank_count].to_s]
          end
          @stdout.puts table_renderer.render(
            headers: ["Column", "Non-blank", "Blank"],
            rows: rows,
            max_width: max_width
          )
        end
      end
    end

    def color_enabled?(mode)
      return true if mode == "always"
      return false if mode == "never"
      return false if @env["NO_COLOR"]

      @stdout.respond_to?(:tty?) && @stdout.tty?
    end

    def colorize(text, code:, enabled:)
      return text unless enabled

      "\e[#{code}m#{text}\e[0m"
    end

    def terminal_width
      columns = @env["COLUMNS"].to_i
      return columns if columns.positive?
      return @stdout.winsize[1] if @stdout.respond_to?(:winsize)

      80
    end
  end
end
