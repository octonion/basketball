#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.basketball-reference.com/leagues"

table_xpath = '//*[@id="games"]/tbody/tr'

#league_id = "ABA"

league_id = "NBA"

first_year = 2016
last_year = 2016

#if (first_year==last_year)
#  stats = CSV.open("csv/games_#{first_year}.csv","w")
#else
#  stats = CSV.open("csv/games_#{first_year}-#{last_year}.csv","w")
#end

(first_year..last_year).each do |year|

#  stats = CSV.open("csv/games_#{league_id}_#{year}.csv","w")
   stats = CSV.open("csv/games_#{year}.csv","w")

  url = "#{base}/#{league_id}_#{year}_games.html"
  print "Pulling year #{year}"

  begin
    page = agent.get(url)
  rescue
    retry
  end

  found = 0
  page.parser.xpath(table_xpath).each do |r|
    row = [year]
    r.xpath("td").each_with_index do |e,i|

      text = e.text.strip rescue nil
      if (text==nil) or (text.size==0)
        text=nil
      end

      if ([0,2].include?(i))

        if (e.xpath("a").first==nil)
          row += [text, nil]
        else
          href = e.xpath("a").first.attribute("href").to_s.strip rescue nil
          row += [text, href]
        end

      elsif ([3,5].include?(i))
        
        if (e.xpath("a").first==nil)
          row += [text, nil, nil]
        else
          href = e.xpath("a").first.attribute("href").to_s.strip rescue nil
          id = href.split("/")[-2]
          row += [text, href, id]
        end
        
      else

        row += [text]

      end

    end

    if (row.size>1)
      found += 1
      stats << row
    end

  end

  print " - found #{found}\n"
  stats.close

end
