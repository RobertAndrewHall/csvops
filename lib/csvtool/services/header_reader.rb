# frozen_string_literal: true

require "csv"

module Csvtool
  module Services
    class HeaderReader
      def call(file_path:, col_sep:)
        first_row = CSV.open(file_path, "r", headers: true, col_sep: col_sep, &:first)
        headers = first_row&.headers || []
        headers.compact.reject(&:empty?)
      end
    end
  end
end
