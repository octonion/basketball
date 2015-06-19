#!/usr/bin/env ruby
# coding: utf-8

require "csv"
require "mechanize"
require "json"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = "Mozilla/5.0"

base = "http://data.nba.com/json/cms/noseason" #/scoreboard"

scoreboard = CSV.open("csv/scoreboard_2013.csv","w")
boxscores = CSV.open("csv/boxscores_2013.csv","w")
pbp = CSV.open("csv/pbp_2013.csv","w")

first_date = Date.new(2012,10,5)
last_date = Date.new(2013,6,20)

#first_date = Date.new(2013,10,5)
#last_date = Date.new(2014,6,15)

#first_date = Date.new(2012,12,1)
#last_date = first_date
#last_date = Date.today

(first_date..last_date).each do |day|

  found = 0

  url = "#{base}/scoreboard/%4d%02d%02d/games.json" % [day.year,day.month,day.day]

  print "Pulling #{day}"

  tries = 0
  begin
    page = agent.get_file(url)
  rescue
    print " -> try #{tries}"
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
    periods = game["period_time"]["period_value"].to_i
    row += [id,periods,game]

    scoreboard << row

    url = "#{base}/game/%4d%02d%02d/#{id}/boxscore.json" % [day.year,day.month,day.day]

    tries = 0
    begin
      boxscore_json = agent.get_file(url)
    rescue
      print " -> try #{tries}\n"
      tries += 1
      retry if (tries<4)
      next
    end

    boxscores << row+[boxscore_json]

    (1..periods).each do |i|

      url = "#{base}/game/%4d%02d%02d/#{id}/pbp_#{i}.json" % [day.year,day.month,day.day]

      tries = 0
      begin
        pbp_json = agent.get_file(url)
      rescue
        print " -> try #{tries}\n"
        tries += 1
        retry if (tries<4)
        next
      end

      pbp << row+[i,pbp_json]

    end

    found += 1

  end

  print " - found #{found}\n"

  pbp.flush
  boxscores.flush

end

pbp.close
boxscores.close
scoreboard.close
