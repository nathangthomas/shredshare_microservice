class RtdLocationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :address

  def location_serializer
    RtdLocation.new()

    
  end

end
