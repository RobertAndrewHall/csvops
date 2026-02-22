# frozen_string_literal: true

module Csvtool
  module Domain
    module CsvSplitSession
      class SplitOptions
        attr_reader :chunk_size, :output_directory, :file_prefix

        def initialize(chunk_size:, output_directory: nil, file_prefix: nil)
          @chunk_size = Integer(chunk_size)
          @output_directory = output_directory
          @file_prefix = file_prefix
        end
      end
    end
  end
end
