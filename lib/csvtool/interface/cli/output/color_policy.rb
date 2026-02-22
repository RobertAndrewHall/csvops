# frozen_string_literal: true

module Csvtool
  module Interface
    module CLI
      module Output
        class ColorPolicy
          def initialize(mode:, io:, env: ENV)
            @mode = mode
            @io = io
            @env = env
          end

          def enabled?
            return true if @mode == "always"
            return false if @mode == "never"
            return false if @env["NO_COLOR"]

            @io.respond_to?(:tty?) && @io.tty?
          end
        end
      end
    end
  end
end
