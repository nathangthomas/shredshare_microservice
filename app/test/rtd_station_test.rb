require 'minitest/autorun'
require 'minitest/pride'
require './app/lib/rtd_station.rb'

class RtdPlaceIdTest < Minitest::Test

  def setup
    @station = RtdPlaceId.new(name: 'Sample Station Name', address: '1234 this is an address')
  end

  def test_it_exists
    assert_instance_of RtdPlaceId, @station
  end

  def test_it_has_attributes
    assert_equal 'Sample Station Name', @station.name
    assert_equal '1234 this is an address', @station.address

  end
end
