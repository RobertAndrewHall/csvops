# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/builders/row_randomization_session_builder"
require "csvtool/domain/shared/output_destination"

class RowRandomizationSessionBuilderTest < Minitest::Test
  def test_builds_row_randomization_session
    builder = Csvtool::Interface::CLI::Workflows::Builders::RowRandomizationSessionBuilder.new
    destination = Csvtool::Domain::Shared::OutputDestination.file(path: "/tmp/out.csv")

    session = builder.call(
      file_path: "/tmp/data.csv",
      col_sep: "\t",
      headers_present: false,
      seed: 12,
      destination: destination
    )

    assert_equal "/tmp/data.csv", session.source.path
    assert_equal "\t", session.source.separator
    assert_equal false, session.source.headers_present?
    assert_equal 12, session.options.seed
    assert_equal true, session.output_destination.file?
  end
end
