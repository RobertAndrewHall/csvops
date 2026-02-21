# frozen_string_literal: true

require "csv"

module Csvtool
  module Infrastructure
    module CSV
      class ValueStreamer
        def each(file_path:, column_name:, col_sep:, skip_blanks:)
          ::CSV.foreach(file_path, headers: true, col_sep: col_sep) do |row|
            value = row[column_name].to_s
            next if skip_blanks && value.strip.empty?

            yield value
          end
        end
      end
    end
  end
end
