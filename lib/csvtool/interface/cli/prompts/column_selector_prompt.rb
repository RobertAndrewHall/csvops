# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Prompts
        class ColumnSelectorPrompt
          def initialize(stdin:, stdout:, errors:)
            @stdin = stdin
            @stdout = stdout
            @errors = errors
          end

          def call(headers)
            @stdout.print "Filter columns (optional): "
            filter = @stdin.gets&.strip.to_s

            filtered_headers = select_headers(headers, filter)
            return nil if filtered_headers.empty?

            @stdout.puts "Select column:"
            filtered_headers.each_with_index do |header, index|
              @stdout.puts "#{index + 1}. #{header}"
            end
            @stdout.print "Column number: "

            selected_header = filtered_headers[@stdin.gets&.strip.to_i - 1]
            return selected_header if selected_header

            @errors.column_not_found
            nil
          end

          private

          def select_headers(headers, filter)
            filtered_headers =
              if filter.empty?
                headers
              else
                headers.select { |header| header.to_s.downcase.include?(filter.downcase) }
              end

            if filtered_headers.empty?
              @errors.column_not_found
              return []
            end
            filtered_headers
          end
        end
      end
    end
  end
end
