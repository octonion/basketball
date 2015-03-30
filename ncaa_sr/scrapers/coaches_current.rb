#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.sports-reference.com"

coach_base = "http://www.sports-reference.com/cbb/seasons" #/1981-coaches.html

table_xpath = '//table/tbody/tr'

years = (2015..2015)

coaches = CSV.open("csv/coaches_current.csv", "w",
                   {:col_sep => ","})

#Coach	School	Conference	W	L	W-L%	AP Pre	AP Post	NCAA Tournament	Since	W	L	W-L%	NCAA	S16	FF	W	L	W-L%	NCAA	S16	FF
header = ["year", "coach", "coach_url",
          "school", "school_url", "school_id",
          "conference", "conference_url", "conference_id",
          "w", "l", "wlp",
          "ap_pre", "ap_post", "ncaa_tournament", "since",
          "cs_w", "cs_l", "cs_wlp", "cs_ncaa", "cs_s16",
          "cs_ff", "co_w", "co_l", "co_wlp", "co_ncaa",
          "co_s16", "co_ff"]

coaches << header

years.each do |year|

  url = "#{coach_base}/#{year}-coaches.html"
  print "Pulling #{year}"

  begin
    page = agent.get(url)
  rescue
    retry
  end

  found = 0
  page.parser.xpath(table_xpath).each do |tr|

    row = [year]
    tr.xpath("td").each_with_index do |td,i|

      et = td.text.strip.gsub(bad,"") rescue nil
      if (et==nil) or (et.size==0)
        et=nil
      end

      case i

      when 0

        if (td.xpath("a").first==nil)
          row += [et, nil]
        else
          href = td.xpath("a").first.attribute("href").to_s
          row += [et, base+href]
        end

      when 1,2

        if (td.xpath("a").first==nil)
          row += [et, nil, nil]
        else
          href = td.xpath("a").first.attribute("href").to_s
          id = href.split("/")[-2]
          row += [et, base+href, id]
        end

      else

        row += [et]

      end

    end

    if (row.size>3)
      found += 1
      coaches << row
    end

  end

  print " - found #{found}\n"

end

coaches.close
