#!/usr/bin/env ruby

require "csv"
require "mechanize"
require "json"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = "Mozilla/5.0"

results = CSV.open("CSV/games_2014.csv","w")

#divisions = ["d1","d2","d3"]
divisions = ["d1"]

#game_date = Date::strptime(testdate, "%d-%m-%Y")

date_start = Date.new(2014,11,16)
date_end = Date.new(2015,1,15)

for div_date in divisions.product(Array(date_start..date_end)) do

  division = div_date[0]
  game_date = div_date[1]

  sb_base_url = "http://data.ncaa.com/jsonp/scoreboard/basketball-men"
  data_base_url = "http://data.ncaa.com/game/basketball-men"

  sb_url = "%s/%s/%s/%02d/%02d/scoreboard.html" % [sb_base_url,division,game_date.year,game_date.month,game_date.day]

  #sleep 5

#  p sb_url

  tries = 0
  begin
    page = agent.get_file(sb_url)
  rescue
    print " -> attempt #{tries}\n"
    tries += 1
    retry if (tries<4)
    next
  end

  print "Found scoreboard for #{division} - #{game_date}\n"

  page = page[/{.+}/m]

  #sb_json = JSON.parse(page) # rescue nil

  #sb_json = JSON.parse(page[/{.+}/m])

  page = page.gsub("\n","")
  page = page.gsub("\t","")
  page = page.gsub("\r","")
  m = page.scan(/,[\s]*,/)
  #p m
  #p m.size
  #if not(m==nil)
  m.each do |v|
    page = page.gsub(v,",")
  end
  #end
  #p ps.match(/,[\s]*,/)
  #ps = ps.gsub(/,[\s]*,/,",")
  sb_json = JSON.parse(page) # rescue nil

  if sb_json==nil
    print " - nil\n"
    next
  end

  sb_json["scoreboard"].each do |day|

    game_date = day["day"]

    found_games = 0

    day["games"].each_with_index do |game,i|

      found_games += 1

      game_id = game["id"]

      row = Hash["gameinfo"=>game]

      tab_path = game["tabs"].split("/basketball-men/")[1]
      url = "#{data_base_url}/#{tab_path}"

      tries = 0
      begin
        page = agent.get_file(url)
      rescue
        print " -> attempt #{tries}\n"
        tries += 1
        retry if (tries<4)
        next
      end

      tabs = JSON.parse(page)

      tabs.each do |tab|
        type = tab["type"]

        file_path = tab["file"].split("/basketball-men/")[1]
        url = "#{data_base_url}/#{file_path}"

        tries = 0
        begin
          page = agent.get_file(url)
          #p url
        rescue
          print " -> attempt #{tries}\n"
          tries += 1
          retry if (tries<4)
          next
        end

        page = page.gsub("\n","")
        page = page.gsub("\t","")
        page = page.gsub("\r","")
        row[type] = JSON.parse(page)

      end

      results << [game_id,
                  game_date,
                  row["gameinfo"].to_json,
                  row["boxscore"].to_json,
                  row["play-by-play"].to_json]

    end

    print "found #{found_games} games\n"

  end

end

results.close
