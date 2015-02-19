#!/usr/bin/env ruby
# coding: utf-8

bad = " "

require 'csv'

require 'nokogiri'
require 'open-uri'

require 'cgi'
require 'date'

team_base = 'http://www.euroleague.net/main/results/by-team'
boxscore_base = 'http://www.euroleague.net/main/results/showgame?gamecode=164&seasoncode=E2013#!boxscore'

score_xpath = '//*[@id="gvResults"]/tr'

#'//*[@id="ctl00_ctl00_ctl00_ctl00_maincontainer_maincenter_contentpane_boxscorepane_ctl00_PartialsStatsByQuarter_dgPartials"]/tbody/tr[1]/th[1]'

first_year = 2013
last_year = 2013

if (first_year==last_year)
  results = CSV.open("games_#{first_year}.csv","w")
else
  results = CSV.open("games_#{first_year}-#{last_year}.csv","w")
end

team_file = CSV.open('teams_2013.csv','r')
#team_file = CSV.open('teams.csv','r')

teams = Array[]
team_file.each { |team| teams << team[1] }
#team_file.each { |team| teams << team[0] }

(first_year..last_year).each do |year|

  print "Pulling year #{year}\n"

  teams.each do |team_id|

    url = "#{team_base}?clubcode=#{team_id}&seasoncode=E#{year}"

    print "  #{team_id}\n"

    begin
      doc = Nokogiri::HTML(open(url))
    rescue
      print "  - not found\n"
      next
      #retry
    end

    doc.xpath(score_xpath).each_with_index do |tr|

      row = [year,team_id]
      tr.xpath("td").each_with_index do |td,i|

        if (i.between?(2,4))
          next
        end

        text = td.text
        text.gsub!(bad,'')
        text.strip!

        if (i.between?(0,4))
          a = td.xpath('a').first
          if not(a==nil || a.attribute("href")==nil)
            html = a.attribute("href").text
          else
            html = nil
          end
        end

        if (i==0)

          if not(html==nil)
            gamecode = CGI::parse(html)['gamecode'][0].to_i
          else
            gamecode = nil
          end

          if (text.start_with?('vs.'))
            text = text[3..-1].strip!
            row += ['home',text,html,gamecode]
          else
            text = text[2..-1].strip!
            row += ['away',text,html,gamecode]
          end
#        elsif (i.between?(1,4))
#          if (text=='')
#            row += [nil,nil]
#          else
#            row += [text,html]
#          end
        else
          if (text=='')
            row += [nil]
          else
            row += [text]
          end
        end

        if (i==1)
          if not(text=='')
            scores = text.split('-')
            home_score = scores[0].strip
            away_score = scores[1].strip
            row += [home_score,away_score]
          else
            row += [nil,nil]
          end
        end

        if (i==5)
          #p DateTime.parse(text)
          if not(text==nil or text=="")
            month = text.split(' ')[0].strip
            #date = DateTime.parse(text).to_date
            #month = date.month
            #day = date.day
            if (['July','August','September','October','November','December'].include?(month))
              game_date = DateTime.parse(year.to_s+' '+text).to_date.to_s
            else
              game_date = DateTime.parse((year+1).to_s+' '+text).to_date.to_s
            end
            row += [game_date]
          else
            row += [nil]
          end
        end

      end

      if (row.size>2)
        results << row
      end

    end

  end

end

results.close
