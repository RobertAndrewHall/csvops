# frozen_string_literal: true

require "csv"

module Csvtool
  class CLI
    MENU_OPTIONS = [
      "Extract column",
      "Exit"
    ].freeze

    def self.start(argv, stdin:, stdout:, stderr:)
      new(argv, stdin: stdin, stdout: stdout, stderr: stderr).run
    end

    def initialize(argv, stdin:, stdout:, stderr:)
      @argv = argv
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
    end

    def run
      case @argv.first
      when "menu"
        run_menu
      else
        print_usage
        1
      end
    end

    private

    def run_menu
      loop do
        print_menu
        @stdout.print "> "

        case @stdin.gets&.strip
        when "1"
          run_extract_column
        when "2"
          return 0
        else
          @stdout.puts "Please choose 1 or 2."
        end
      end
    end

    def print_menu
      @stdout.puts "CSV Tool Menu"
      MENU_OPTIONS.each_with_index do |option, index|
        @stdout.puts "#{index + 1}. #{option}"
      end
    end

    def print_usage
      @stderr.puts "Usage: tool menu"
    end

    def run_extract_column
      @stdout.print "CSV file path: "
      file_path = @stdin.gets&.strip.to_s

      unless File.file?(file_path)
        @stdout.puts "File not found: #{file_path}"
        return
      end

      col_sep = choose_separator
      return if col_sep.nil?

      headers = read_headers(file_path, col_sep)
      if headers.empty?
        @stdout.puts "No headers found."
        return
      end

      column_name = choose_column_name(headers)
      return if column_name.nil?

      skip_blanks = choose_skip_blanks
      preview_values = build_preview_values(file_path, column_name, col_sep, skip_blanks: skip_blanks, limit: 10)
      return unless confirm_print_all_values(preview_values)

      stream_column_values(file_path, column_name, col_sep, skip_blanks: skip_blanks) do |value|
        @stdout.puts value
      end
    rescue CSV::MalformedCSVError
      @stdout.puts "Could not parse CSV file."
    rescue Errno::EACCES
      @stdout.puts "Cannot read file: #{file_path}"
    end

    def choose_separator
      @stdout.puts "Choose separator:"
      @stdout.puts "1. comma (,)"
      @stdout.puts "2. tab (\\t)"
      @stdout.puts "3. semicolon (;)"
      @stdout.puts "4. pipe (|)"
      @stdout.puts "5. custom"
      @stdout.print "Separator choice [1]: "

      case @stdin.gets&.strip.to_s
      when "", "1" then ","
      when "2" then "\t"
      when "3" then ";"
      when "4" then "|"
      when "5"
        @stdout.print "Custom separator: "
        custom = @stdin.gets&.strip.to_s
        return custom unless custom.empty?

        @stdout.puts "Separator cannot be empty."
        nil
      else
        @stdout.puts "Invalid separator choice."
        nil
      end
    end

    def choose_column_name(headers)
      @stdout.print "Filter columns (optional): "
      filter = @stdin.gets&.strip.to_s

      filtered_headers =
        if filter.empty?
          headers
        else
          headers.select { |header| header.to_s.downcase.include?(filter.downcase) }
        end

      if filtered_headers.empty?
        @stdout.puts "Column not found."
        return nil
      end

      @stdout.puts "Select column:"
      filtered_headers.each_with_index do |header, index|
        @stdout.puts "#{index + 1}. #{header}"
      end
      @stdout.print "Column number: "

      selected_header = filtered_headers[@stdin.gets&.strip.to_i - 1]
      return selected_header if selected_header

      @stdout.puts "Column not found."
      nil
    end

    def choose_skip_blanks
      @stdout.print "Skip blank values? [Y/n]: "
      answer = @stdin.gets&.strip.to_s.downcase
      !%w[n no].include?(answer)
    end

    def confirm_print_all_values(preview_values)
      @stdout.puts "Preview (first #{preview_values.length} values):"
      preview_values.each { |value| @stdout.puts value }
      @stdout.print "Print all values? [y/N]: "

      answer = @stdin.gets&.strip.to_s.downcase
      return true if %w[y yes].include?(answer)

      @stdout.puts "Canceled."
      false
    end

    def read_headers(file_path, col_sep)
      first_row = CSV.open(file_path, "r", headers: true, col_sep: col_sep, &:first)
      headers = first_row&.headers || []
      headers.compact.reject(&:empty?)
    end

    def build_preview_values(file_path, column_name, col_sep, skip_blanks:, limit:)
      preview_values = []
      stream_column_values(file_path, column_name, col_sep, skip_blanks: skip_blanks) do |value|
        preview_values << value
        break if preview_values.length >= limit
      end
      preview_values
    end

    def stream_column_values(file_path, column_name, col_sep, skip_blanks:)
      CSV.foreach(file_path, headers: true, col_sep: col_sep) do |row|
        value = row[column_name].to_s
        next if skip_blanks && value.strip.empty?

        yield value
      end
    end
  end
end
