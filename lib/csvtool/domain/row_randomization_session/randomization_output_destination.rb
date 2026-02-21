# frozen_string_literal: true

module Csvtool
  module Domain
    module RowRandomizationSession
      class RandomizationOutputDestination
        attr_reader :mode, :path

        def self.console
          new(mode: :console)
        end

        def self.file(path:)
          new(mode: :file, path: path)
        end

        def initialize(mode:, path: nil)
          raise ArgumentError, "invalid output mode" unless %i[console file].include?(mode)
          raise ArgumentError, "file output path cannot be empty" if mode == :file && path.to_s.empty?

          @mode = mode
          @path = path
        end

        def file?
          @mode == :file
        end
      end
    end
  end
end
