class CopData
  @@app_id = $config['app_id']
  @@app_key = $config['app_key']
  @@unique_field = ''
  attr_accessor :cop_id
  def self.get_options(url,field_name)
    tmphash = {}
    response = RestClient.get(url, :content_type => :json,:accept => :json,:'X-Knack-Application-Id' => @@app_id,:'X-Knack-REST-API-KEY' => @@app_key )
    found = JSON.parse(response.body)
    found["records"].each {|ids| tmphash[ids[field_name]] = ids["id"] }
    return tmphash
  end
  def operation(part)
    part.operation
  end
  def select(filter)
    search_url = self.base_url + '?rows_per_page=1000&filters=' + URI.encode(filter.to_json)
    begin
      response = RestClient.get(search_url, :content_type => :json,:accept => :json,:'X-Knack-Application-Id' => @@app_id,:'X-Knack-REST-API-KEY' => @@app_key )
      found_cs = JSON.parse(response.body)
      return found_cs["records"]
    rescue StandardError => e
      return nil
    end
  end
  def find_cop_id(uniquepartid)
    filters = [{"field":"#{@@unique_field}","operator":"is","value": "#{uniquepartid}"}]
    search_url = self.base_url + '?filters=' + URI.encode(filters.to_json)
    begin
      response = RestClient.get(search_url, :content_type => :json,:accept => :json,:'X-Knack-Application-Id' => @@app_id,:'X-Knack-REST-API-KEY' => @@app_key )
      found_cs = JSON.parse(response.body)
      if found_cs["records"].count > 2  then
        raise  "Actually I found more than 2 of these: " + uniquepartid.to_s + ", and that's bad."
      elsif found_cs["records"].count == 1 then
        return  found_cs["records"][0]["id"]
      else
        return raise "Couldn't find part on the cop: " + uniquepartid.to_s
      end

    rescue StandardError => e
      return nil
    end
  end
  def create
    insert_url = self.base_url
    request = self.to_json
    begin
      if $dryrun then return true end
      response = RestClient.post(insert_url,request,:content_type => :json,:accept => :json,:'X-Knack-Application-Id' => @@app_id,:'X-Knack-REST-API-KEY' => @@app_key )
      if response.code >= 200 and response.code <= 300 then
        obj = JSON.parse(response.body)
        return obj["id"]
      else
        return "0"
      end
    rescue StandardError => e
      return "0"
    end
  end
  def update(id)
    request = self.to_json
    update_url = self.base_url + "/#{id}"
    begin
      if $dryrun then return true end
      response = RestClient.put(update_url,request,:content_type => :json,:accept => :json,:'X-Knack-Application-Id' => @@app_id,:'X-Knack-REST-API-KEY' => @@app_key )
      if response.code >= 200 and response.code <= 300 then return true else return false end
    rescue StandardError => e
      return false
    end
  end
  def delete(id)
    delete_url = self.base_url + "/#{id}"
    begin
      if $dryrun then return true end
      response = RestClient.delete(delete_url,:content_type => :json,:accept => :json,:'X-Knack-Application-Id' => @@app_id,:'X-Knack-REST-API-KEY' => @@app_key )
      if response.code >= 200 and response.code <= 300 then return true else return false end
    rescue StandardError => e
      return true
    end
  end
end
