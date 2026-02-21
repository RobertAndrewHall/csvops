# frozen_string_literal: true

module Csvtool
  module Prompts
    class SkipBlanksPrompt
      def initialize(stdin:, stdout:)
        @stdin = stdin
        @stdout = stdout
      end

      def call
        @stdout.print "Skip blank values? [Y/n]: "
        answer = @stdin.gets&.strip.to_s.downcase
        !%w[n no].include?(answer)
      end
    end
  end
end
