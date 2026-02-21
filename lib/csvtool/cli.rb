# frozen_string_literal: true

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
          @stdout.puts "Extract column is not implemented yet."
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
  end
end
