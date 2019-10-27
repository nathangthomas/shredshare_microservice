require 'pry'

class RtdLocation

  attr_reader :name, :address, :city

  def initialize(name, address)
    @name = name
    @address = address
    @city = address.split(",")[1].strip
  end
end
