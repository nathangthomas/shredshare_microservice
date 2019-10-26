require 'pry'

class Coordinates
  attr_reader :formatted_coords

  def initialize(latitude, longitude)
    @formatted_coords = "#{latitude}, #{longitude}"
  end
end
