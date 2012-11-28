#!/usr/bin/ruby1.9.3
# coding: utf-8

bad = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.basketball-reference.com/leagues"
gl_base = "http://www.basketball-reference.com/players"
#/a/acyqu01/gamelog/2013/

table_xpath = '//*[@id="totals"]/tbody/tr'
gl_basic_xpath = '//*[starts-with(@id,"pgl_basic")]/tbody/tr'
gl_advanced_xpath = '//*[starts-with(@id,"pgl_advanced")]/tbody/tr'
#'//*[@id="pgl_basic.1"]'
#starts-with(.,'2552')

first_year = 2013
last_year = 2013

if (first_year==last_year)
  basic = CSV.open("game_logs_basic_#{first_year}.csv","w")
  advanced = CSV.open("game_logs_advanced_#{first_year}.csv","w")
else
  basic = CSV.open("game_logs_basic_#{first_year}-#{last_year}.csv","w")
  advanced = CSV.open("game_logs_advanced_#{first_year}-#{last_year}.csv","w")
end

(first_year..last_year).each do |year|

  url = "#{base}/NBA_#{year}_stats.html"
  print "Pulling year #{year}"

  begin
    page = agent.get(url)
  rescue
    retry
  end

  players = []
  page.parser.xpath(table_xpath).each do |r|

    r.xpath("td").each_with_index do |e,i|

      if (i==1)

        if (e.xpath("a").first==nil)
          next
        else
          player_href = e.xpath("a").first.attribute("href").to_s
        end

        player_id = player_href.split("/")[-1].split(".")[0]
        players << player_id

      else
        next
      end

    end

  end

  print " - found #{players.size} players\n"

  players.each do |player_id|

    gl_url = "#{gl_base}/#{player_id[0]}/#{player_id}/gamelog/#{year}/"

    begin
      page = agent.get(gl_url)
    rescue
      retry
    end

    page.parser.xpath(gl_basic_xpath).each do |tr|
      row = [year,player_id]
      tr.xpath("td").each_with_index do |td,i|
        field = td.text
        if (field==nil) or (field.size==0)
          row << nil
        else
          row << field
        end
      end
      if (row.size>2)
        basic << row
      end
    end

    basic.flush

    page.parser.xpath(gl_advanced_xpath).each do |tr|
      row = [year,player_id]
      tr.xpath("td").each_with_index do |td,i|
        field = td.text
        if (field==nil) or (field.size==0)
          row << nil
        else
          row << field
        end
      end
      if (row.size>2)
        advanced << row
      end
    end

    advanced.flush

  end
end

basic.close
advanced.close
