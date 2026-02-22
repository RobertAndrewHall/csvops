# frozen_string_literal: true

require_relative "../../../test_helper"

class UseCaseIoBoundaryTest < Minitest::Test
  USE_CASE_GLOB = File.expand_path("../../../../lib/csvtool/application/use_cases/*.rb", __dir__)
  FORBIDDEN_PATTERNS = [
    /CSV\.open/,
    /File\.open\([^)]*,\s*["']w/,
    /File\.write\(/,
    /IO\.write\(/
  ].freeze

  def test_use_cases_do_not_perform_direct_file_writes
    violations = []

    Dir.glob(USE_CASE_GLOB).sort.each do |file_path|
      content = File.read(file_path)
      FORBIDDEN_PATTERNS.each do |pattern|
        violations << "#{file_path}: #{pattern.inspect}" if content.match?(pattern)
      end
    end

    assert_equal [], violations, "Found forbidden direct write APIs in use cases:\n#{violations.join("\n")}"
  end
end
