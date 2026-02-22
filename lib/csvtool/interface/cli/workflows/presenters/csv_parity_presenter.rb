# frozen_string_literal: true

require "csvtool/interface/cli/output/colorizer"

module Csvtool
  module Interface
    module CLI
      module Workflows
        module Presenters
          class CsvParityPresenter
            def initialize(stdout:, colorizer: Output::Colorizer.auto(io: stdout))
              @stdout = stdout
              @colorizer = colorizer
            end

            def print_summary(data)
              @stdout.puts(data[:match] ? @colorizer.call("MATCH", code: "32") : @colorizer.call("MISMATCH", code: "31"))
              @stdout.puts "Summary: left_rows=#{data[:left_rows]} right_rows=#{data[:right_rows]} " \
                           "left_only=#{data[:left_only_count]} right_only=#{data[:right_only_count]}"
              return if data[:match]

              print_examples("Left-only examples", data[:left_only_examples])
              print_examples("Right-only examples", data[:right_only_examples])
            end

            private

            def print_examples(label, examples)
              return if examples.nil? || examples.empty?

              @stdout.puts "#{label}:"
              examples.each do |example|
                @stdout.puts "  #{example[:row]} (count +#{example[:count_delta]})"
              end
            end
          end
        end
      end
    end
  end
end
