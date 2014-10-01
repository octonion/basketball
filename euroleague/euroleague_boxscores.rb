#!/usr/bin/ruby1.9.3
# coding: utf-8

bad = " "

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent_alias = 'Mac Safari'
agent.robots = false

#boxscore_base = 'http://www.euroleague.net/main/results/showgame?gamecode=164&seasoncode=E2013#!boxscore'
linescore_base = 'http://www.euroleague.net/main/results/showgame'

linescore_xpath = '//*[@id="ctl00_ctl00_ctl00_ctl00_maincontainer_maincenter_contentpane_boxscorepane_ctl00_PartialsStatsByQuarter_dgPartials"]/tr'

#//*[@id="tblTeamStats"]/tbody/tr[4]

#ctl00_ctl00_ctl00_ctl00_maincontainer_maincenter_contentpane_boxscorepane_ctl00_PartialsStatsEndOfQuarter_dgPartials

game_id = 164
year = 2013

url = "#{linescore_base}?gamecode=#{game_id}&seasoncode=E#{year}#!boxscore"

begin
  page = agent.get(url)
rescue
  print "  - not found\n"
  exit
end

row = [year,game_id]

page.parser.xpath(linescore_xpath).each do |tr|

  row = [year,game_id]

  tr.xpath('./th|./td').each do |td|

    text = td.text
    text.gsub!(bad,'')
    text.strip!

    row << text

  end

  p row

end
