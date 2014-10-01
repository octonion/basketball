#!/usr/bin/ruby1.9.3
# coding: utf-8

bad = " "

require 'csv'

require 'nokogiri'
require 'open-uri'

require 'cgi'

base = 'http://www.euroleague.net/main/results/by-team' #?seasoncode=E2011'

table_xpath = '//*[@id="el-layout"]/div[4]/div[3]/div/div[2]/div[3]/ul/li/a'

first_year = 2013
last_year = 2013

if (first_year==last_year)
  results = CSV.open("teams_#{first_year}.csv","w")
else
  results = CSV.open("teams_#{first_year}-#{last_year}.csv","w")
end

(first_year..last_year).each do |year|

  team_url = "#{base}/?seasoncode=E#{year}"

  begin
    doc = Nokogiri::HTML(open(team_url))
  rescue
    retry
  end

  doc.xpath(table_xpath).each_with_index do |team|

    team_name = team.text.strip
    team_url = team.attribute('href').text
    team_id = CGI::parse(team_url)['clubcode'][0].strip

    row = [year,team_id,team_name,team_url,0]
    results << row
  end

end

results.close
