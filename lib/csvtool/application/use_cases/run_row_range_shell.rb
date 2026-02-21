# frozen_string_literal: true

module Csvtool
  module Application
    module UseCases
      class RunRowRangeShell
        def initialize(stdout:)
          @stdout = stdout
        end

        def call
          @stdout.puts "Row-range extraction workflow"
          @stdout.puts "Coming next: extract rows x..y."
        end
      end
    end
  end
end
