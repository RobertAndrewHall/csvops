# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      class MenuLoop
        def initialize(stdin:, stdout:, menu_options:, extract_column_action:, extract_rows_action:, randomize_rows_action:)
          @stdin = stdin
          @stdout = stdout
          @menu_options = menu_options
          @extract_column_action = extract_column_action
          @extract_rows_action = extract_rows_action
          @randomize_rows_action = randomize_rows_action
        end

        def run
          loop do
            print_menu
            @stdout.print "> "
            choice = @stdin.gets
            return 0 if choice.nil?

            case choice.strip
            when "1"
              @extract_column_action.call
            when "2"
              @extract_rows_action.call
            when "3"
              @randomize_rows_action.call
            when "4"
              return 0
            else
              @stdout.puts "Please choose 1, 2, 3, or 4."
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
