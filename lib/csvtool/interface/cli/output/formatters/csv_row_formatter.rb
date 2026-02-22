# frozen_string_literal: true

require "csv"

module Csvtool
  module Interface
    module CLI
      module Output
        module Formatters
          class CsvRowFormatter
            def call(fields:, col_sep:)
              ::CSV.generate_line(fields, row_sep: "", col_sep: col_sep).chomp
            end
          end
        end
      end
    end
  end
end
