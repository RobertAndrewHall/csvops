# frozen_string_literal: true

require "csvtool/menu_loop"
require "csvtool/extract_column_workflow"

module Csvtool
  class CLI
    MENU_OPTIONS = [
      "Extract column",
      "Exit"
    ].freeze

    def self.start(argv, stdin:, stdout:, stderr:)
      new(argv, stdin: stdin, stdout: stdout, stderr: stderr).run
    end

    def initialize(argv, stdin:, stdout:, stderr:)
      @argv = argv
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
    end

    def run
      case @argv.first
      when "menu"
        run_menu_loop
      else
        print_usage
        1
      end
    end

    private

    def run_menu_loop
      workflow = ExtractColumnWorkflow.new(stdin: @stdin, stdout: @stdout)
      MenuLoop.new(stdin: @stdin, stdout: @stdout, menu_options: MENU_OPTIONS, extract_workflow: workflow).run
    end

    def print_usage
      @stderr.puts "Usage: tool menu"
    end
  end
end
