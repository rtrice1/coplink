class CriticalSpareInventoryData < CopData
  ssaisrid_url = 'https://api.blackhalldigital.com/v1/objects/object_56/records?rows_per_page=1000'
  @@ssaiserid = CopData.get_options(ssaisrid_url,"field_829")
  location_url = 'https://api.blackhalldigital.com/v1/objects/object_66/records?rows_per_page=1000'
  @@locations = CopData.get_options(location_url,"field_1011")
  
  def base_url
    "https://api.blackhalldigital.com/v1/objects/object_55/records"
  end
  def unique_field
    'field_846'
  end

  def initialize(part, dryrun)
    @field_809 = part.PartId
    @field_810 = part.PartNumber
    @field_811 = part.Description
    @field_812 = part.Details
    @field_813 = part.locationgroup
    @field_814 = part.Location
    @field_815 = part.serialnumber
    @field_816 = part.LastUpdatedDate
    @field_819 = part.criticallevel
    @field_832 = [@@ssaiserid[part.SSAISRID]]
    if ! @@locations[part.Location].nil? then
      @field_1014 = [@@locations[part.Location]]
    else
      loc = Location.new(part.Location,$dryrun)
      id = loc.create
      @@locations[part.Location] = id;
      @field_1014 = [@@locations[part.Location]]
    end
  end


end
