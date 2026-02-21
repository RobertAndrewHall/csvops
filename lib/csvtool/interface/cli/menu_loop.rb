# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      class MenuLoop
        def initialize(stdin:, stdout:, menu_options:, extract_column_action:, extract_rows_action:)
          @stdin = stdin
          @stdout = stdout
          @menu_options = menu_options
          @extract_column_action = extract_column_action
          @extract_rows_action = extract_rows_action
        end

        def run
          loop do
            print_menu
            @stdout.print "> "

            case @stdin.gets&.strip
            when "1"
              @extract_column_action.call
            when "2"
              @extract_rows_action.call
            when "3"
              return 0
            else
              @stdout.puts "Please choose 1, 2, or 3."
            end
          end
        end

        private

        def print_menu
          @stdout.puts "CSV Tool Menu"
          @menu_options.each_with_index do |option, index|
            @stdout.puts "#{index + 1}. #{option}"
          end
        end
      end
    end
  end
end
