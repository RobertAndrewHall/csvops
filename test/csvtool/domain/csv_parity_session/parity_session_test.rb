# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/csv_parity_session/source_pair"
require "csvtool/domain/csv_parity_session/parity_options"
require "csvtool/domain/csv_parity_session/parity_session"

class ParitySessionTest < Minitest::Test
  def test_stores_source_pair_and_options
    source_pair = Csvtool::Domain::CsvParitySession::SourcePair.new(left_path: "/tmp/l.csv", right_path: "/tmp/r.csv")
    options = Csvtool::Domain::CsvParitySession::ParityOptions.new(separator: ",", headers_present: true)

    session = Csvtool::Domain::CsvParitySession::ParitySession.start(source_pair: source_pair, options: options)

    assert_equal source_pair, session.source_pair
    assert_equal options, session.options
  end
end
