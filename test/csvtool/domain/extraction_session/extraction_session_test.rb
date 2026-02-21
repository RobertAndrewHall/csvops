# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/extraction_session/extraction_session"
require "csvtool/domain/extraction_session/csv_source"
require "csvtool/domain/extraction_session/separator"
require "csvtool/domain/extraction_session/column_selection"
require "csvtool/domain/extraction_session/extraction_options"
require "csvtool/domain/extraction_session/preview"
require "csvtool/domain/extraction_session/extraction_value"
require "csvtool/domain/extraction_session/output_destination"

class ExtractionSessionTest < Minitest::Test
  def test_state_transitions
    session = Csvtool::Domain::ExtractionSession::ExtractionSession.start(
      source: Csvtool::Domain::ExtractionSession::CsvSource.new(
        path: "/tmp/in.csv",
        separator: Csvtool::Domain::ExtractionSession::Separator.new(",")
      ),
      column_selection: Csvtool::Domain::ExtractionSession::ColumnSelection.new(name: "name"),
      options: Csvtool::Domain::ExtractionSession::ExtractionOptions.new(skip_blanks: true, preview_limit: 10)
    )

    preview = Csvtool::Domain::ExtractionSession::Preview.new(
      values: [Csvtool::Domain::ExtractionSession::ExtractionValue.new("Alice")]
    )
    session = session.with_preview(preview).confirm!.with_output_destination(
      Csvtool::Domain::ExtractionSession::OutputDestination.console
    )

    assert_equal true, session.confirmed?
    assert_equal preview, session.preview
    assert_equal true, session.output_destination.console?
  end
end
