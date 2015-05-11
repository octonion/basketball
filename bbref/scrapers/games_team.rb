#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

#"http://www.basketball-reference.com/leagues"
base = "http://www.basketball-reference.com/teams" #/GSW/2015_games.html
table_xpath = '//*[@id="teams_games"]/tbody/tr'
#//*[@id="teams_games"]/tbody/tr[1]

first_year = 2015
last_year = 2015

#if (first_year==last_year)
#  stats = CSV.open("csv/games_#{first_year}.csv","w")
#else
#  stats = CSV.open("csv/games_#{first_year}-#{last_year}.csv","w")
#end

(first_year..last_year).each do |year|

  stats = CSV.open("csv/games_team_#{year}.csv","w")

  CSV.open("csv/standings_#{year}.csv","r").each do |team|

    found = 0

    team_id = team[4]

    url = "#{base}/#{team_id}/#{year}_games.html"

    print "Pulling #{year}/#{team_id} -"

    begin
      page = agent.get(url)
    rescue
      retry
    end

    page.parser.xpath(table_xpath).each do |r|
      row = [year]
      r.xpath("td").each_with_index do |e,i|

        et = e.text
        if (et==nil) or (et.size==0)
          et=nil
        end

        if ([1,4,6].include?(i))

          if (e.xpath("a").first==nil)
            row += [et,nil]
          else
            row += [et,e.xpath("a").first.attribute("href").to_s]
          end

        else

          row += [et]

        end

      end

      if (row.size>1)
        found += 1
        stats << row
      end

    end

    print " - found #{found}\n"
  end
  stats.close

end
