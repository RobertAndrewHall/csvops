# frozen_string_literal: true

module Csvtool
  module Domain
    module CsvParitySession
      class ParitySession
        attr_reader :source_pair, :options

        def self.start(source_pair:, options:)
          new(source_pair: source_pair, options: options)
        end

        def initialize(source_pair:, options:)
          @source_pair = source_pair
          @options = options
        end
      end
    end
  end
end
