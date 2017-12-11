class PodataCriticalSpareInventoryData < CopData
  def base_url
    "https://api.blackhalldigital.com/v1/objects/object_52/records"
  end
  def unique_field
    'field_787'
  end

  ssaisrid_url = 'https://api.blackhalldigital.com/v1/objects/object_56/records?rows_per_page=1000'
  @@ssaiserid = CopData.get_options(ssaisrid_url,"field_829")
  uniqueid_url = 'https://api.blackhalldigital.com/v1/objects/object_55/records?rows_per_page=1000'
  @@uniquepartid = CopData.get_options(uniqueid_url,"field_846")

  def initialize(part, dryrun)
    @field_787 = part.podata_id
    @field_698 = part.num
    @field_699 = part.polineitem
    @field_700 = part.partnum
    @field_844 = part.serialnum
    @field_847 = [@@uniquepartid["#{part.partnum}:#{part.serialnum}"]]
    @field_834 = [@@ssaiserid[part.ssaisrid]]
    @field_701 = part.revision
    @field_702 = part.description
    @field_704 = part.qtytofulfill
    @field_708 = part.polineitemnote
    @field_986 = part.DateReceived
    @field_713 = part.LastMemoEntry
    @field_716 = part.Status
    @field_743 = part.requestingsite
  end
end
