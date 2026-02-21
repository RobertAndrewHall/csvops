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

      unless headers.include?(column_name)
        @stdout.puts "Column not found."
        return
      end

      extract_column_values(file_path, column_name, col_sep).each do |value|
        @stdout.puts value
      end
    rescue CSV::MalformedCSVError
      @stdout.puts "Could not parse CSV file."
    rescue Errno::EACCES
      @stdout.puts "Cannot read file: #{file_path}"
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

      selected_index = @stdin.gets&.strip.to_i
      selected_header = filtered_headers[selected_index - 1]
      return selected_header if selected_header

      @stdout.puts "Column not found."
      nil
    end

    def read_headers(file_path, col_sep)
      first_row = CSV.open(file_path, "r", headers: true, col_sep: col_sep, &:first)
      headers = first_row&.headers || []
      headers.compact.reject(&:empty?)
    end

    def extract_column_values(file_path, column_name, col_sep)
      values = []

      CSV.foreach(file_path, headers: true, col_sep: col_sep) do |row|
        values << row[column_name]
      end

      values
    end
  end
end
    def choose_separator
      @stdout.puts "Choose separator:"
      @stdout.puts "1. comma (,)"
      @stdout.puts "2. tab (\\t)"
      @stdout.puts "3. semicolon (;)"
      @stdout.puts "4. pipe (|)"
      @stdout.puts "5. custom"
      @stdout.print "Separator choice [1]: "
      choice = @stdin.gets&.strip.to_s

      case choice
      when "", "1" then ","
      when "2" then "\t"
      when "3" then ";"
      when "4" then "|"
      when "5"
        @stdout.print "Custom separator: "
        custom = @stdin.gets&.strip.to_s
        if custom.empty?
          @stdout.puts "Separator cannot be empty."
          nil
        else
          custom
        end
      else
        @stdout.puts "Invalid separator choice."
        nil
      end
    end
