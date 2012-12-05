#!/usr/bin/ruby1.9.3
# coding: utf-8

require "csv"
require "mechanize"
require "json"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = "Mozilla/5.0"

base = "http://data.nba.com/json/cms/noseason" #/scoreboard"

scoreboard = CSV.open("scoreboard_2013.csv","w")
boxscores = CSV.open("boxscores_2013.csv","w")
pbp = CSV.open("pbp_2013.csv","w")

first_date = Date.new(2012,10,7)
#first_date = Date.new(2012,12,1)
#last_date = first_date
last_date = Date.today

(first_date..last_date).each do |day|

  url = "#{base}/scoreboard/%4d%02d%02d/games.json" % [day.year,day.month,day.day]

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

  sb_json = JSON.parse(page)

  sb_json["sports_content"]["games"]["game"].each do |game|

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
      print " -> attempt #{tries}\n"
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
        print " -> attempt #{tries}\n"
        tries += 1
        retry if (tries<4)
        next
      end

      pbp << row+[i,pbp_json]

    end

    pbp.flush

  end

  boxscores.flush

end

pbp.close
boxscores.close
scoreboard.close
