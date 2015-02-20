#!/usr/bin/env ruby

require 'csv'

require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

#require 'nokogiri'

nthreads = 10

base_sleep = 0
sleep_increment = 3
retries = 4

# Base URLs

anonymouse_base_url = "http://anonymouse.org/cgi-bin/anon-www.cgi/"

ncaa_base_url = "http://web1.ncaa.org/stats/exec/records"

# Example NCAA URL
#http://web1.ncaa.org/stats/exec/records?academicYear=2014&sportCode=MBB&orgId=26172

game_xpath = "//table/tr[3]/td/form/table[2]/tr[position()>1]"
record_xpath = "//table/tr[3]/td/form/table[1]/tr[2]"

games_header = ["year","school_name","school_id","opponent_name","opponent_id",
                "game_date","school_score","opponent_score","location",
                "neutral_site_location","game_length","attendance"]

records_header = ["year","school_id","school_name","wins","losses","ties",
                  "total_games"]

ncaa_schools = CSV.read("csv/schools.csv")

schools = []
ncaa_schools.each do |school|
  schools << school
end

n = schools.size

tpt = (n.to_f/nthreads.to_f).ceil

first_year = 2014
last_year = 2014

(first_year..last_year).each do |year|

  ncaa_games = CSV.open("csv/ncaa_games_#{year}_mt.csv","w",{:col_sep => "\t"})
  ncaa_records = CSV.open("csv/ncaa_records_#{year}_mt.csv","w",{:col_sep => "\t"})

  ncaa_games << games_header
  ncaa_records << records_header

  threads = []

  schools.each_slice(tpt).with_index do |schools_slice,i|

    threads << Thread.new(schools_slice) do |t_schools|

      school_count = 0
      game_count = 0

      t_schools.each_with_index do |school,j|

        sleep_time = base_sleep

        school_id = school[0]
        school_name = school[1]

        print "#{year}/#{school_name} (#{school_count}/#{game_count})\n"

        url = ncaa_base_url+"?academicYear=#{year}&sportCode=MBB&orgId=#{school_id}"
        tries = 0
        begin
          page = agent.post(url, {"academicYear" => "#{year}",
                              "orgId" => school_id,
                              "sportCode" => "MBB"})
        rescue
          sleep_time += sleep_increment
          #print "sleep #{sleep_time} ... "
          sleep sleep_time
          tries += 1
          if (tries > retries)
            next
          else
            retry
          end
        end

        doc = page.parser

        sleep_time = base_sleep

        begin
          doc.xpath(record_xpath).each do |row|
            r = []
            row.xpath("td").each do |d|
              r += [d.text.strip]
            end
            school_count += 1
            ncaa_records << [year,school_id]+r
          end
          #records.flush
        end

        doc.xpath(game_xpath).each do |row|
          r = []
          row.xpath("td").each do |d|
            r += [d.text.strip,d.inner_html.strip]
          end
          #      if (r[0]=="Opponent")
          #        next
          #      end
          opponent_id = r[1][/(\d+)/]
          game_count += 1
          ncaa_games << [year,school_name,school_id,r[0],opponent_id,
                         r[2],r[4],r[6],r[8],r[10],r[12],r[14]]
        end

        #games.flush

      end

    end
  end

  threads.each(&:join)

  ncaa_games.close
  ncaa_records.close

end
