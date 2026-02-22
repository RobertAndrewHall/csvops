# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Output
        class Streams
          attr_reader :data, :ui

          def self.build(data:, ui: data)
            new(data: data, ui: ui)
          end

          def initialize(data:, ui:)
            @data = data
            @ui = ui
          end
        end
      end
    end
  end
end
