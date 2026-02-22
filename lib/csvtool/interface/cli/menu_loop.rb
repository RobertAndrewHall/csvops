# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      class MenuLoop
        def initialize(stdin:, stdout:, stderr: stdout, menu_options:, extract_column_action:, extract_rows_action:, randomize_rows_action:, dedupe_action:, parity_action:, split_action:, stats_action:)
          @stdin = stdin
          @stdout = stdout
          @stderr = stderr
          @menu_options = menu_options
          @extract_column_action = extract_column_action
          @extract_rows_action = extract_rows_action
          @randomize_rows_action = randomize_rows_action
          @dedupe_action = dedupe_action
          @parity_action = parity_action
          @split_action = split_action
          @stats_action = stats_action
        end

        def run
          loop do
            print_menu
            @stderr.print "> "
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
              @dedupe_action.call
            when "5"
              @parity_action.call
            when "6"
              @split_action.call
            when "7"
              @stats_action.call
            when "8"
              return 0
            else
              @stderr.puts "Please choose 1, 2, 3, 4, 5, 6, 7, or 8."
            end
          end
        end

        private

        def print_menu
          @stderr.puts "CSV Tool Menu"
          @menu_options.each_with_index do |option, index|
            @stderr.puts "#{index + 1}. #{option}"
          end
        end
      end
    end
  end
end
