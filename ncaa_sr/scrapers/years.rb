#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.sports-reference.com"

table_xpath = '//table/tbody/tr'

schools = CSV.open("csv/schools.csv", "r",
                   {:col_sep => ",", :headers => TRUE})

years = CSV.open("csv/years.csv", "w",
                 {:col_sep => ","})

header = ["school_id", "school_name", "row_number",
          "year", "season", "school_year_url",
          "conference_name", "conference_url",
          "wins", "losses", "wl_pct",
          "srs", "sos", "ppg", "oppg", "ap_pre", "ap_high", "ap_final",
          "ncaa_tournament",
          "coach", "coach_url"]

years << header

schools.each do |school|

  school_name = school["school_name"]
  school_url = school["school_url"]
  school_id = school_url.split("/")[-1]

  url = base+school_url
  print "Pulling #{school_name}"

  begin
    page = agent.get(url)
  rescue
    retry
  end

  found = 0
  page.parser.xpath(table_xpath).each do |r|

    row = [school_id, school_name]
    r.xpath("td").each_with_index do |e,i|

      et = e.text.strip.gsub(bad,"") rescue nil
      if (et==nil) or (et.size==0)
        et=nil
      end

      case i
      when 1

        year = 1+et.split("-")[0].to_i

        if (e.xpath("a").first==nil)
          row += [year,et,nil]
        else
          row += [year,et,e.xpath("a").first.attribute("href").to_s]
        end

      when 2,14

        if (e.xpath("a").first==nil)
          row += [et,nil]
        else
          row += [et,e.xpath("a").first.attribute("href").to_s]
        end

      else

        row += [et]

      end

    end

    if (row.size>2)
      found += 1
      years << row
    end

  end

  print " - found #{found}\n"

end

years.close
