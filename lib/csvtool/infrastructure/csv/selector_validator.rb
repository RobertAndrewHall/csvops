# frozen_string_literal: true

require "csv"
require "csvtool/infrastructure/csv/header_reader"

module Csvtool
  module Infrastructure
    module CSV
      class SelectorValidator
        def initialize(header_reader: HeaderReader.new)
          @header_reader = header_reader
        end

        def valid?(profile:, selector:)
          if selector.headers_present?
            headers = @header_reader.call(file_path: profile.path, col_sep: profile.separator)
            return false if headers.empty?

            headers.include?(selector.value)
          else
            first_row = ::CSV.open(profile.path, "r", headers: false, col_sep: profile.separator, &:first)
            return false if first_row.nil?

            selector.value <= first_row.length
          end
        end
      end
    end
  end
end
