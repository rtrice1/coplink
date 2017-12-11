class Location < CopData
  def base_url
    "https://api.blackhalldigital.com/v1/objects/object_66/records"
  end

  def initialize(location, dryrun)
    @field_1011 = location
    @field_1012 = 'available'
    @field_1017 = '1'
    @field_1019 = 'N/A'
    @field_1024 = '0'
  end
end
