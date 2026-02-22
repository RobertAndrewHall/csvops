# frozen_string_literal: true

require_relative "../../../../../../test_helper"
require "csvtool/interface/cli/workflows/steps/cross_csv_dedupe/collect_options_step"
require "csvtool/domain/cross_csv_dedupe_session/csv_profile"

class CrossCsvDedupeCollectOptionsStepTest < Minitest::Test
  class FakeErrors
    attr_reader :column_not_found_called

    def column_not_found
      @column_not_found_called = true
    end
  end

  def test_halts_when_source_selector_invalid
    selector_prompt = Object.new
    yes_no_prompt = Object.new
    output_destination_prompt = Object.new
    session_builder = Object.new
    mapper = Object.new
    errors = FakeErrors.new

    def selector_prompt.call(label:, headers_present:) = nil

    step = Csvtool::Interface::CLI::Workflows::Steps::CrossCsvDedupe::CollectOptionsStep.new(
      selector_prompt: selector_prompt,
      yes_no_prompt: yes_no_prompt,
      output_destination_prompt: output_destination_prompt,
      errors: errors
    )

    source = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(path: "/tmp/a.csv", separator: ",", headers_present: true)
    reference = Csvtool::Domain::CrossCsvDedupeSession::CsvProfile.new(path: "/tmp/b.csv", separator: ",", headers_present: true)

    result = step.call(source: source, reference: reference, session_builder: session_builder, output_destination_mapper: mapper)

    assert_equal :halt, result
    assert_equal true, errors.column_not_found_called
  end
end
