#!/usr/bin/ruby1.9.3

require "csv"
require "mechanize"
require "hpricot"

#game_date,conference_id,conference_name,home_team,home_team_site,away_team,away_team_site,time/score,boxscore_link,webcast_text,webcast_javascript

agent = Mechanize.new
agent.user_agent = 'Mozilla/5.0'

base="http://www.dakstats.com/WebSync/Pages/Conference/ConferenceSchedule.aspx"

header = ["comp_id","conference_id","conference_name","game_date","home_name","home_href","home_id","away_name","away_href","away_id","score","time","conf_game","status","box_score_href"]

association="10"
sg="MBB"

conferences = CSV.read("conferences.csv")

first_year = 2012
last_year = 2012

(first_year..last_year).each do |year|

  games = CSV.open("naia_games_#{year}.csv","w")

  games << header

  sea = "NAIMBB_#{year}"

  conferences.each do |conference|
    conf_id = conference[0]
    conf_name = conference[1]
    print "Pulling #{year} - #{conf_name}\n"
    url = "#{base}?association=#{association}&sg=#{sg}&sea=#{sea}&conference=#{conf_id}"

    begin
      page = agent.get(url)
    rescue
      print "Error: Retrying\n"
      retry
      #print "missing\n"
    end

    table_xpath = "//*[@id='ctl00_websyncContentPlaceHolder_scheduleDataList']"

    rows = []
    row = []
    game_date = nil
    page.parser.xpath(table_xpath).each do |t|

      t.xpath("//table[(@class='subHeaderTable') or (@class='defaultRow')]//tr/td").each do |r|
        if (r.path.to_s =~ /\/tr\/td\z/)
          game_date = r.text.strip
        else
          if (r.path =~ /\/tr\/td\[1\]\z/)
            row = [game_date,r.text.strip,r.inner_html.strip]
          elsif (r.path =~ /\/tr\/td\[2\]\z/)
            row += [r.text.strip,r.inner_html.strip]
          elsif (r.path =~ /\/tr\/td\[3\]\z/)
            row += [r.text.strip,r.inner_html.strip]
          elsif (r.path =~ /\/tr\/td\[4\]\z/)
            #row += [r.text.strip,r.inner_html.strip]
            rows << row
            row = []
          end
        end
      end
    end

    rows.each do |row|
      home_id = nil
      away_id = nil
      home_href = row[2]
      if not((home_href==nil) or (home_href.size==0))
        home_id = home_href[/team=(\d+)/]
        if not(home_id==nil)
          home_id = home_id[/(\d+)/]
        end
      end
      away_href = row[4]
      if not((away_href==nil) or (away_href.size==0))
        away_id = away_href[/team=(\d+)/]
        if not(away_id==nil)
          away_id = away_id[/(\d+)/]
        end
      end
      if (row[5].include?("f"))
        status = "forfeit"
        row[5].gsub!("f","")
      else
        status = nil
      end
      if (row[5].include?("*"))
        time_score = row[5].split("*")[0].strip
        conf_game=TRUE
      else
        time_score = row[5].strip
        conf_game=FALSE
      end
      if (time_score.include?(":"))
        time = time_score
        score = nil
      else
        score = time_score
        time = nil
      end
      comp_id = row[6][/compID=(\d+)/]
      if not(comp_id==nil)
        comp_id = comp_id[/(\d+)/]
      end
      games << [comp_id,conf_id,conf_name]+row[0..2]+[home_id]+row[3..4]+[away_id,score,time,conf_game,status,row[6]]
    end

  end

  games.close

end

=begin

  a += [d.text.strip]
end
rows << a

page.parser.xpath("//table[@class='gridViewReportBuilderWide']//tr").each do |row|
  a = []
  row.xpath("td").each do |d|
    a += [d.text.strip]
  end
  if not(a==[])
    rows << a
  end
end
stats = CSV.open("naia_test.csv","w")

rows.each do |row|
  stats << row
end
stats.close
=end
