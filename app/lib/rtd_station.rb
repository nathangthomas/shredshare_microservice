require 'pry'

class RtdPlaceId

  attr_reader :name, :place_id

  def initialize(data)
    @name = data[:name]
    @place_id = data[:place_id]
  end

end
