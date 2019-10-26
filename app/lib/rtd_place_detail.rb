require 'pry'

class RtdPlaceDetail

  attr_reader :name, :address
  def initialize(name, address)
    # binding.pry
    @name = name
    @address = address
  end
end
