# frozen_string_literal: true

module Csvtool
  module Domain
    module ColumnSession
      class ExtractionOptions
        attr_reader :skip_blanks, :preview_limit

        def initialize(skip_blanks:, preview_limit:)
          raise ArgumentError, "preview_limit must be positive" unless preview_limit.to_i.positive?

          @skip_blanks = !!skip_blanks
          @preview_limit = preview_limit
        end

        def skip_blanks?
          @skip_blanks
        end
      end
    end
  end
end
