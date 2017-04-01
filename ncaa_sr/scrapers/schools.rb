#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

url = "http://www.sports-reference.com/cbb/schools/"

table_xpath = '//*[@id="schools"]/tbody/tr'

schools = CSV.open("csv/schools.csv", "w", {:col_sep => ","})

schools << ["rk","school","school_url","school_id","from","to","yrs","g","w","l","wl_pct","srs","sos","ap","creg","ctrn","ncaa","ff","nc"]

begin
  page = agent.get(url)
rescue
  retry
end

found = 0
page.parser.xpath(table_xpath).each do |r|

  row = []
  r.xpath("td|th").each_with_index do |e,i|

    et = e.text
    if (et==nil) or (et.size==0)
      et=nil
    end

    case i
    when 1

      if (e.xpath("a").first==nil)
        row += [et, nil, nil]
      else
        href = e.xpath("a").first.attribute("href").to_s
        id = href.split("/")[-1]
        row += [et, e.xpath("a").first.attribute("href").to_s, id]
      end

    else

      row += [et]

    end

  end

  if (row.size>1) and not(row[0]=="Rk")
    found += 1
    schools << row
  end

end

print "Schools found #{found}\n"

schools.close
