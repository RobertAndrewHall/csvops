# frozen_string_literal: true

require "csvtool/application/use_cases/run_extraction"

module Csvtool
  class ExtractColumnWorkflow
    def initialize(stdin:, stdout:)
      @run_extraction = Application::UseCases::RunExtraction.new(stdin: stdin, stdout: stdout)
    end

    def run
      @run_extraction.call
    end
  end
end
