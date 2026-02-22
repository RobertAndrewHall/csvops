# frozen_string_literal: true

module Csvtool
  module Domain
    module CsvSplitSession
      class SplitOptions
        attr_reader :chunk_size, :output_directory, :file_prefix, :overwrite_existing

        def initialize(chunk_size:, output_directory: nil, file_prefix: nil, overwrite_existing: false)
          @chunk_size = Integer(chunk_size)
          @output_directory = output_directory
          @file_prefix = file_prefix
          @overwrite_existing = overwrite_existing
        end
      end
    end
  end
end
