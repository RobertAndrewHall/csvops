# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/application/use_cases/run_csv_parity"

class RunCsvParityTest < Minitest::Test
  def test_returns_success_with_paths
    result = Csvtool::Application::UseCases::RunCsvParity.new.call(
      left_path: "/tmp/left.csv",
      right_path: "/tmp/right.csv"
    )

    assert_equal true, result.ok?
    assert_equal "/tmp/left.csv", result.data[:left_path]
    assert_equal "/tmp/right.csv", result.data[:right_path]
  end
end
