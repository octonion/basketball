#!/usr/bin/env ruby
# coding: utf-8

require 'csv'

require 'nokogiri'
require 'open-uri'

require 'cgi'

base = 'http://www.euroleague.net'

team_base = 'http://www.euroleague.net/competition/teams' #?seasoncode=E2013

table_xpath = '//*[contains(concat(" ", @class, " "), concat(" ", "RoasterName", " "))]//a'

#table_xpath = '//*[@id="el-layout"]/div[4]/div[3]/div/div[2]/div[3]/ul/li/a'

first_year = 2015
last_year = 2015

if (first_year==last_year)
  results = CSV.open("csv/teams_#{first_year}.csv","w")
else
  results = CSV.open("csv/teams_#{first_year}-#{last_year}.csv","w")
end

results << ["year", "team_id", "team_name", "team_url"]

(first_year..last_year).each do |year|
  p year

  team_url = "#{team_base}/?seasoncode=E#{year}"

  begin
    doc = Nokogiri::HTML(open(team_url))
  rescue
    retry
  end

  doc.xpath(table_xpath).each_with_index do |team|
    team_name = team.text.strip rescue nil
    team_url = base+team.attribute('href')
    team_id = CGI::parse(team_url.split('?')[1])['clubcode'][0].strip rescue nil

    row = [year, team_id, team_name, team_url]
    results << row
  end

end

results.close
