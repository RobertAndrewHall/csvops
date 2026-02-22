# frozen_string_literal: true

require "csvtool/interface/cli/output/color_policy"

module Csvtool
  module Interface
    module CLI
      module Output
        class Colorizer
          def initialize(policy:)
            @policy = policy
          end

          def call(text, code:)
            return text unless @policy.enabled?

            "\e[#{code}m#{text}\e[0m"
          end

          def self.auto(io:, env: ENV)
            new(policy: ColorPolicy.new(mode: "auto", io: io, env: env))
          end
        end
      end
    end
  end
end
