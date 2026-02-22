# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/row_randomization_session/randomization_session"
require "csvtool/domain/row_randomization_session/randomization_source"
require "csvtool/domain/row_randomization_session/randomization_options"
require "csvtool/domain/shared/output_destination"

class RandomizationSessionTest < Minitest::Test
  def test_with_output_destination_returns_updated_session
    source = Csvtool::Domain::RowRandomizationSession::RandomizationSource.new(
      path: "/tmp/in.csv",
      separator: ",",
      headers_present: true
    )
    options = Csvtool::Domain::RowRandomizationSession::RandomizationOptions.new(seed: 7)
    session = Csvtool::Domain::RowRandomizationSession::RandomizationSession.start(source: source, options: options)
    destination = Csvtool::Domain::Shared::OutputDestination.console

    updated = session.with_output_destination(destination)

    assert_equal source, updated.source
    assert_equal options, updated.options
    assert_equal destination, updated.output_destination
  end
end
