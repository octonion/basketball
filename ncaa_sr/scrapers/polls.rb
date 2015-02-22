#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.sports-reference.com/cbb/schools"

weeks_xpath = '//table[@id="polls"]/thead/tr/th'
ranks_xpath = '//table[@id="polls"]/tr/td'

years = CSV.open("csv/years.csv", "r",
                 {:col_sep => ",", :headers => TRUE})

polls = CSV.open("csv/polls.csv", "w",
                 {:col_sep => ","})

header = ["year", "school_id", "school_name", "week", "rank"]

polls << header

years.each do |school_year|

  year = school_year["year"]
  school_id = school_year["school_id"]
  school_name = school_year["school_name"]
  school_year_url = school_year["school_year_url"]

  if (school_year_url==nil)
    next
  end

  if (year=="2015")
    next
  end
  if (year.to_i<1980)
    next
  end

  url = "#{base}/#{school_id}/#{year}-schedule.html"
  print "Pulling #{school_name} #{year}"

  begin
    page = agent.get(url)
  rescue
    retry
  end

  found = 0
  row = [year,school_id,school_name]

  weeks = []
  page.parser.xpath(weeks_xpath).each do |th|
    text = th.text.strip.gsub(bad,"") rescue nil
    if (text==nil or text.size==0)
      text=nil
    end
    weeks += [text]
  end

  ranks = []
  page.parser.xpath(ranks_xpath).each do |td|
    text = td.text.strip.gsub(bad,"") rescue nil
    if (text==nil or text.size==0)
      text=nil
    end
    ranks += [text]
  end

  weeks.each_with_index do |week,i|
    polls << row+[week,ranks[i]]
    found += 1
  end

  print " - found #{found}\n"

end

polls.close
