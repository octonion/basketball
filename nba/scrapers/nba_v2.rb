#!/usr/bin/env ruby
# coding: utf-8

require "csv"
require "mechanize"
require "json"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = "Mozilla/5.0"

base = "http://data.nba.com/json/cms/noseason" #/scoreboard"

scoreboard = CSV.open("csv/scoreboard_2015.csv","w")
boxscores = CSV.open("csv/boxscores_2015.csv","w")
pbp = CSV.open("csv/pbp_2015.csv","w")

boxscore_start = "http://stats.nba.com/stats/boxscore?EndPeriod=10&EndRange=55800&GameID="
boxscore_end = "&RangeType=2&Season=2014-15&SeasonType=Regular+Season&StartPeriod=1&StartRange=0"

pbp_start = "http://stats.nba.com/stats/playbyplayv2?EndPeriod=10&EndRange=55800&GameID="
pbp_end = "&RangeType=2&Season=2014-15&SeasonType=Regular+Season&StartPeriod=1&StartRange=0"

first_date = Date.new(2014,10,4)
last_date = Date.new(2015,6,16)

(first_date..last_date).each do |day|

  found = 0

  url = "#{base}/scoreboard/%4d%02d%02d/games.json" % [day.year,day.month,day.day]

  print "Pulling #{day}"

  tries = 0
  begin
    page = agent.get_file(url)
  rescue
    print " -> attempt #{tries}\n"
    tries += 1
    retry if (tries<4)
    print " - found #{found}\n"
    next
  end

  sb_json = JSON.parse(page)

  #p sb_json

  games = sb_json["sports_content"]["games"]["game"] rescue nil

  if (games==nil)
    print " - found #{found}\n"
    next
  end

  games.each do |game|

    row = [day]

    id = game["id"]
    #periods = game["period_time"]["period_value"].to_i
    periods = game["period_time"]["total_periods"].to_i
    row += [id,periods,game]

    scoreboard << row

    url = boxscore_start+id+boxscore_end

    tries = 0
    begin
      boxscore_json = agent.get_file(url)
    rescue
      print " -> attempt #{tries}\n"
      tries += 1
      retry if (tries<4)
      next
    end

    boxscores << row+[boxscore_json]

    url = pbp_start+id+pbp_end

    tries = 0
    begin
      pbp_json = agent.get_file(url)
    rescue
      print " -> attempt #{tries}\n"
      tries += 1
      retry if (tries<4)
      next
    end

    # 0 is for legacy, and indicates 'all periods'

    pbp << row+[0,pbp_json]

    found += 1

  end

  print " - found #{found}\n"

  #pbp.flush
  #boxscores.flush

end

pbp.close
boxscores.close
scoreboard.close
