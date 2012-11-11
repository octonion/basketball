#!/usr/bin/ruby1.9.1

require "csv"
require "mechanize"
require "rexml/document"

include REXML

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = "Mozilla/5.0"

results = CSV.open("geocodes.csv","w")
locations = CSV.open("ncaa_locations.csv","r")

base_url = "http://where.yahooapis.com/geocode"

locations.each do |location|

  school_name = location[0]
  school_id = location[1]
  city_state = location[2]

  print "Pulling geocode for #{city_state}\n"

  url = "#{base_url}?q=#{city_state}&appid=[yourappidhere]"

  tries = 0
  begin
    doc = agent.get_file(url)
  rescue
    print " -> attempt #{tries}\n"
    tries += 1
    retry if (tries<4)
    next
  end

  page = Document.new(doc).root

  long = XPath.first(page,"//longitude")
  lat = XPath.first(page,"//latitude")

  case long
  when nil
    longitude = nil
  else
    longitude = long.text
  end

  case lat
  when nil
    latitude = nil
  else
    latitude = lat.text
  end

  row = [school_name,school_id,city_state,longitude,latitude]

  results << row

end

results.close

exit 0
