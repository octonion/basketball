#!/usr/bin/ruby1.9.3

require "csv"
require "rexml/document"
require "xmlsimple"

include REXML

game_file =  CSV.open("game.csv","w")
period_file =  CSV.open("period.csv","w")
special_file =  CSV.open("special.csv","w")
summary_file =  CSV.open("summary.csv","w")
play_file =  CSV.open("play.csv","w")

period_a = ["number","time"]

special_a = ["vh","pts_to","pts_ch2","pts_paint","pts_fastb","pts_bench","ties","leads","poss_count","poss_time","score_count","score_time","large_lead","large_lead_t"]

summary_a = ["vh","fgm","fga","fgm3","fga3","ftm","fta","blk","stl","ast","oreb","dreb","treb","pf","tf","to"]

play_a = ["vh","time","uni","team","checkname","action","type","paint","vscore","hscore","play_id"]

$*.each do |file|

  file_name = File.basename(file)
  event_id = file_name.split("_")[0]

  game_file << [event_id]

  if (File.size(file)<1000)
    print "  #{file_name} is too short\n"
    next
  end
      
  xml_file = Document.new(File.open(file)).root

  #x = XmlSimple.xml_in(File.open(file))
  #CSV.open("data.csv", "wb") {|csv| x.to_a.each {|elem| csv << elem} }

  xml_file.elements.each("/plays") do |game|

    print "Parsing #{event_id}\n"

    game.elements.each("period") do |period|

      period_av = [event_id]

      period_a.each do |a|
        period_av << period.attributes[a]
      end

      period_file << period_av

      period.elements.each("special") do |special|

        special_av = [event_id,period_av[1]]

        special_a.each do |a|
          special_av << special.attributes[a]
        end
      
        special_file << special_av
      end

      period.elements.each("summary") do |summary|

        summary_av = [event_id,period_av[1]]

        summary_a.each do |a|
          summary_av << summary.attributes[a]
        end
      
        summary_file << summary_av
      end

      period.elements.each("play") do |play|

        play_av = [event_id,period_av[1]]

        play_a.each do |a|
          play_av << play.attributes[a]
        end
      
        play_file << play_av
      end

    end
  end
end

game_file.close
period_file.close
special_file.close
summary_file.close
play_file.close
