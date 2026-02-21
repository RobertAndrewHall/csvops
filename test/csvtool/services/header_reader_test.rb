# frozen_string_literal: true

require_relative "../../test_helper"
require "csvtool/services/header_reader"

class HeaderReaderTest < Minitest::Test
  def fixture_path(name)
    File.expand_path("../../fixtures/#{name}", __dir__)
  end

  def test_returns_headers
    reader = Csvtool::Services::HeaderReader.new
    headers = reader.call(file_path: fixture_path("sample_people.csv"), col_sep: ",")
    assert_equal %w[name city], headers
  end
end
