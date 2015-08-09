#!/usr/bin/env ruby
# coding: utf-8

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = "Mozilla/5.0"

url = "http://stats.nba.com/tracking/#!/player/catchshoot/"

player_xpath = '//td[@class="player ng-scope"]'

tries = 0
begin
  page = agent.get(url)
rescue
  print " -> attempt #{tries}\n"
  tries += 1
  retry if (tries<4)
end

page.parser.css(".player .ng-binding").each do |player|
  p player
end
