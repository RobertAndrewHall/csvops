# frozen_string_literal: true

require_relative "../../../../../test_helper"
require "csvtool/interface/cli/workflows/support/output_destination_mapper"

class OutputDestinationMapperTest < Minitest::Test
  def test_maps_console_destination
    mapper = Csvtool::Interface::CLI::Workflows::Support::OutputDestinationMapper.new

    destination = mapper.call({ mode: :console })

    assert_equal true, destination.console?
  end

  def test_maps_file_destination
    mapper = Csvtool::Interface::CLI::Workflows::Support::OutputDestinationMapper.new

    destination = mapper.call({ mode: :file, path: "/tmp/out.csv" })

    assert_equal true, destination.file?
    assert_equal "/tmp/out.csv", destination.path
  end
end
