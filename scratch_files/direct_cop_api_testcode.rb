require 'rest_client'
require 'json'


request = '{"field_809":3757,"field_810":"8429213-3","field_811":"AWAPPS","field_812":"AWAPPS","field_813":"OCONUS Site 1C","field_814":"CH2","field_815":"9006","field_816":"10/05/2016","field_819":"1.0","field_832":"SSA-BAE-13157"}'

base_url = 'https://api.blackhalldigital.com/v1/objects/object_55/records'
filters = [{"field":"field_846","operator":"is","value":'8429213-3:9006'}];
search_url=base_url + '?filters=' + URI.encode(filters.to_json)

response = RestClient.get(search_url,:content_type => :json,:accept => :json,:'X-Knack-Application-Id' => "58d905fc9e279c20a92b2c8a",:'X-Knack-REST-API-KEY' => "8f54d050-1edf-11e7-9d8c-5f9f1f834bde" )

found_cs = JSON.parse(response.body)
puts found_cs["records"][0]["id"]
