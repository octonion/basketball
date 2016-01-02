#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.basketball-reference.com/leagues"

east_xpath = '//table[@id="E_standings"]/tbody/tr'

west_xpath = '//table[@id="W_standings"]/tbody/tr'

first_year = 2016
last_year = 2016

#if (first_year==last_year)
#  stats = CSV.open("csv/games_#{first_year}.csv","w")
#else
#  stats = CSV.open("csv/games_#{first_year}-#{last_year}.csv","w")
#end

(first_year..last_year).each do |year|

  stats = CSV.open("csv/standings_#{year}.csv","w")

  standings_url = "#{base}/NBA_#{year}.html"
  print "Pulling year #{year}"

  begin
    page = agent.get(standings_url)
  rescue
    retry
  end

  found = 0
  division = nil
  page.parser.xpath(east_xpath).each do |r|

    row = [year, "east", division]
    r.xpath("td").each_with_index do |e,i|

      et = e.text
      if (et==nil) or (et.size==0)
        et=nil
      end

      case i
      when 0

        if (e.xpath("a").first==nil)
          row += [et,nil,nil]
        else
          url = e.xpath("a").first.attribute("href").to_s
          team_id = url.split("/")[2]
          row += [et, team_id, url]
        end

      else

        row += [et]

      end

    end

    if not(row[4]==nil)
      found += 1
      stats << row
    else
      division = row[3]
    end

  end

  print " - found #{found},"

  found = 0
  page.parser.xpath(west_xpath).each do |r|

    row = [year, "west", division]
    r.xpath("td").each_with_index do |e,i|

      et = e.text
      if (et==nil) or (et.size==0)
        et=nil
      end

      case i
      when 0

        if (e.xpath("a").first==nil)
          row += [et,nil,nil]
        else
          url = e.xpath("a").first.attribute("href").to_s
          team_id = url.split("/")[2]
          row += [et, team_id, url]
        end

      else

        row += [et]

      end

    end

    if not(row[4]==nil)
      found += 1
      stats << row
    else
      division = row[3]
    end

  end

  print " found #{found}\n"

  stats.close

end
