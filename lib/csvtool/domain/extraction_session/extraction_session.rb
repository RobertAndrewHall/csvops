# frozen_string_literal: true

module Csvtool
  module Domain
    module ExtractionSession
      class ExtractionSession
        attr_reader :source, :column_selection, :options, :preview, :output_destination

        def self.start(source:, column_selection:, options:)
          new(source: source, column_selection: column_selection, options: options)
        end

        def initialize(source:, column_selection:, options:, preview: nil, output_destination: nil, confirmed: false)
          @source = source
          @column_selection = column_selection
          @options = options
          @preview = preview
          @output_destination = output_destination
          @confirmed = confirmed
        end

        def with_preview(preview)
          self.class.new(
            source: @source,
            column_selection: @column_selection,
            options: @options,
            preview: preview,
            output_destination: @output_destination,
            confirmed: @confirmed
          )
        end

        def confirm!
          self.class.new(
            source: @source,
            column_selection: @column_selection,
            options: @options,
            preview: @preview,
            output_destination: @output_destination,
            confirmed: true
          )
        end

        def with_output_destination(destination)
          self.class.new(
            source: @source,
            column_selection: @column_selection,
            options: @options,
            preview: @preview,
            output_destination: destination,
            confirmed: @confirmed
          )
        end

        def confirmed?
          @confirmed
        end
      end
    end
  end
end
