#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

#url = "http://www.ncaa.com/stats/baseball/d1"
url = "http://www.ncaa.com/stats/basketball-men/d1"

results = CSV.open("ncaa_schools.csv","w")

begin
  page = agent.get(url)
rescue
  print "  -> error, retrying\n"
  retry
end

path="//*[@id='edit-searchOrg']"

#puts page.parser.xpath(path).to_html

page.parser.xpath(path).each do |menu|

  menu.xpath("option").each do |option|
    school_id = option.attributes["value"].value
    school_name = option.inner_text
    results << [school_id,school_name]
    results.flush
  end

end

results.close
