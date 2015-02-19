#!/usr/bin/env ruby

require 'csv'
require 'mechanize'

agent = Mechanize.new{ |agent| agent.history.max_size=0 }

agent.user_agent = 'Mozilla/5.0'

#url = "http://web1.ncaa.org/stats/exec/records"
#url = "http://web1.ncaa.org/stats/StatsSrv/careersearch"

# Needed for referer

url = "http://web1.ncaa.org/stats/StatsSrv/careerteam"
agent.get(url)

#schools = CSV.read("schools.csv")
schools = CSV.read("ncaa_schools.csv")

first_year = 2015
last_year = 2015

(first_year..last_year).each do |year|
  stats = CSV.open("ncaa_players_#{year}.csv","w")

  schools.each do |school|

    school_id = school[0]
    school_name = school[1]
    print "#{year}/#{school_name}\n"

    begin
      page = agent.post(url, {
                          "academicYear" => "#{year}",
                          "orgId" => school_id,
                          "sportCode" => "MBB",
                          "sortOn" => "0",
                          "doWhat" => "display",
                          "playerId" => "-100",
                          "coachId" => "-100",
                          "division" => "1",
                          "idx" => ""
                        })
    rescue
      print "  -> error, retrying\n"
      retry
    end

    page.parser.xpath("//table[5]/tr").each do |row|
      if (row.path =~ /\/tr\[[123]\]\z/)
        next
      end
      r = [school_name,school_id,year]
      row.xpath("td").each_with_index do |d,i|
        if (i==0) then
          id = d.inner_html.strip[/(\d+)/].to_i
          r += [d.text.strip,id]
        else
          r += [d.text.strip]
        end
      end

      stats << r
      stats.flush
    end
  end

  stats.close
end
