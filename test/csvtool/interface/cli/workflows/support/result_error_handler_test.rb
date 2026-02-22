# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/support/result_error_handler"

class ResultErrorHandlerTest < Minitest::Test
  Result = Struct.new(:error)

  def test_dispatches_mapped_error_action
    calls = []
    errors = Object.new
    handler = Csvtool::Interface::CLI::Workflows::Support::ResultErrorHandler.new(errors: errors)
    result = Result.new(:no_headers)

    handler.call(result, {
      no_headers: ->(_r, _e) { calls << :called }
    })

    assert_equal [:called], calls
  end

  def test_ignores_unmapped_error
    calls = []
    errors = Object.new
    handler = Csvtool::Interface::CLI::Workflows::Support::ResultErrorHandler.new(errors: errors)
    result = Result.new(:unknown)

    handler.call(result, {
      no_headers: ->(_r, _e) { calls << :called }
    })

    assert_empty calls
  end
end
