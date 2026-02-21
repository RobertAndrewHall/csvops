# frozen_string_literal: true

module Csvtool
  module Domain
    module RowSession
      class RowSource
        attr_reader :path, :separator

        def initialize(path:, separator:)
          @path = path
          @separator = separator
        end
      end
    end
  end
end
