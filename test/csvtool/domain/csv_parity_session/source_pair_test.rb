# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/csv_parity_session/source_pair"

class SourcePairTest < Minitest::Test
  def test_requires_paths
    assert_raises(ArgumentError) { Csvtool::Domain::CsvParitySession::SourcePair.new(left_path: "", right_path: "/tmp/r.csv") }
    assert_raises(ArgumentError) { Csvtool::Domain::CsvParitySession::SourcePair.new(left_path: "/tmp/l.csv", right_path: "") }
  end
end
