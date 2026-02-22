# frozen_string_literal: true

require_relative "../../../test_helper"
require "csvtool/domain/csv_parity_session/parity_options"

class ParityOptionsTest < Minitest::Test
  def test_requires_separator
    assert_raises(ArgumentError) do
      Csvtool::Domain::CsvParitySession::ParityOptions.new(separator: "", headers_present: true)
    end
  end

  def test_exposes_headers_present
    options = Csvtool::Domain::CsvParitySession::ParityOptions.new(separator: ",", headers_present: false)
    assert_equal false, options.headers_present?
  end
end
