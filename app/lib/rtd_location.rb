require 'pry'
require 'fast_jsonapi'

class RtdLocation

  attr_reader :name, :address

  def initialize(name, address)
    @name = name
    @address = address
  end

end
