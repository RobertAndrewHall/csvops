# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/column_session/column_session"
require "csvtool/domain/column_session/csv_source"
require "csvtool/domain/column_session/separator"
require "csvtool/domain/column_session/column_selection"
require "csvtool/domain/column_session/extraction_options"
require "csvtool/domain/column_session/preview"
require "csvtool/domain/column_session/extraction_value"
require "csvtool/domain/shared/output_destination"

class ColumnSessionTest < Minitest::Test
  def test_state_transitions
    session = Csvtool::Domain::ColumnSession::ColumnSession.start(
      source: Csvtool::Domain::ColumnSession::CsvSource.new(
        path: "/tmp/in.csv",
        separator: Csvtool::Domain::ColumnSession::Separator.new(",")
      ),
      column_selection: Csvtool::Domain::ColumnSession::ColumnSelection.new(name: "name"),
      options: Csvtool::Domain::ColumnSession::ExtractionOptions.new(skip_blanks: true, preview_limit: 10)
    )

    preview = Csvtool::Domain::ColumnSession::Preview.new(
      values: [Csvtool::Domain::ColumnSession::ExtractionValue.new("Alice")]
    )
    session = session.with_preview(preview).confirm!.with_output_destination(
      Csvtool::Domain::Shared::OutputDestination.console
    )

    assert_equal true, session.confirmed?
    assert_equal preview, session.preview
    assert_equal true, session.output_destination.console?
  end
end
