#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"
require "json"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

#sb_base = "http://data.sportsillustrated.cnn.com/basketball/nba/scoreboards"
#json_base = "http://data.sportsillustrated.cnn.com/basketball/nba/gameflash"

sb_base = "http://www.si.com/pbp/liveupdate?sport=nba&pbp=false&box=false&json=1&date=" #2015-3-2

json_base = "http://www.si.com/pbp/liveupdate?json=1&sport=basketball%2Fnba&box=true&pbp=true&linescore=true&id=" #1349030

scoreboard = CSV.open("scoreboard_2015.csv","w")
games = CSV.open("games_2015.csv","w")

first_date = Date.new(2014,12,1)
last_date = Date.today

(first_date..last_date).each do |day|

  url = "%s-%s-%s" % [sb_base,day.year,day.month,day.day]

  print "Pulling #{day}\n"

  tries = 0
  begin
    page = agent.get_file(url)
  rescue
    print " -> attempt #{tries}\n"
    tries += 1
    retry if (tries<4)
    next
  end

  scoreboard << [day,page]

  si_json = JSON.parse(page)

  si_json["contests"].each do |contest|
    id = contest["id"]

    url = "%s%s" % [json_base,id]

    tries = 0
    begin
      recap = agent.get_file(url)
    rescue
      print " -> attempt #{tries}\n"
      tries += 1
      retry if (tries<4)
      recap = nil
    end

=begin
    url = "%s/%4d/%02d/%02d/%s_boxscore.json" % [json_base,day.year,day.month,day.day,id]
    tries = 0
    begin
      recap = agent.get_file(url)
    rescue
      print " -> attempt #{tries}\n"
      tries += 1
      retry if (tries<4)
      boxscore = nil
    end

    url = "%s/%4d/%02d/%02d/%s_playbyplay.json" % [json_base,day.year,day.month,day.day,id]
    tries = 0
    begin
      playbyplay = agent.get_file(url)
    rescue
      print " -> attempt #{tries}\n"
      tries += 1
      retry if (tries<4)
      playbyplay = nil
    end
=end

#    games << [day,id,recap,boxscore,playbyplay]
    games << [day,id,recap]

  end

end
