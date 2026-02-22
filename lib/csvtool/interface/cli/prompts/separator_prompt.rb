# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class SeparatorPrompt
          DEFAULT_LABEL = "Choose separator:"

          def initialize(stdin:, stdout:, errors:)
            @stdin = stdin
            @stdout = stdout
            @errors = errors
          end

          def call(label: DEFAULT_LABEL)
            @stdout.puts label
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

              @errors.empty_custom_separator
              nil
            else
              @errors.invalid_separator_choice
              nil
            end
          end
        end
      end
    end
  end
end
