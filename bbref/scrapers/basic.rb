#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.basketball-reference.com/leagues"

table_xpath = '//*[@id="totals"]/tbody/tr'

first_year = 2015
last_year = 2015

if (first_year==last_year)
  stats = CSV.open("csv/basic_#{first_year}.csv","w")
else
  stats = CSV.open("csv/basic_#{first_year}-#{last_year}.csv","w")
end

(first_year..last_year).each do |year|

  url = "#{base}/NBA_#{year}_stats.html"
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

      et = e.text
      if (et==nil) or (et.size==0)
        et=nil
      end

      if ([1,3].include?(i))

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
