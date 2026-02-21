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

      column_name = choose_column_name(file_path)
      return if column_name.nil?

      extract_column_values(file_path, column_name).each do |value|
        @stdout.puts value
      end
    end

    def choose_column_name(file_path)
      headers = CSV.open(file_path, "r", headers: true, &:first)&.headers || []

      @stdout.print "Filter columns (optional): "
      filter = @stdin.gets&.strip.to_s

      filtered_headers =
        if filter.empty?
          headers
        else
          headers.select { |header| header.to_s.downcase.include?(filter.downcase) }
        end

      @stdout.puts "Select column:"
      filtered_headers.each_with_index do |header, index|
        @stdout.puts "#{index + 1}. #{header}"
      end
      @stdout.print "Column number: "

      selected_index = @stdin.gets&.strip.to_i
      filtered_headers[selected_index - 1]
    end

    def extract_column_values(file_path, column_name)
      values = []

      CSV.foreach(file_path, headers: true) do |row|
        values << row[column_name]
      end

      values
    end
  end
end
