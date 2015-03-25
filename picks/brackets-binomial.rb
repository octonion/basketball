#!/usr/bin/env ruby

require 'csv'

outcomes = CSV.read("csv/espn-counts.csv") #, {:headers => TRUE})

b = Hash.new

outcomes.each do |outcome|
  team = outcome[0].to_i
  opponent = outcome[1].to_i
  n = outcome[2].to_i
  #team = outcome["team"].to_i
  #opponent = outcome["opponent"].to_i
  #n = outcome["n"].to_i
  b[[team,opponent]] = n
end

for i in 1..64 do
  for j in i+1..64 do
    if b[[i,j]]==nil
      b[[i,j]] = 0
    end
    if b[[j,i]]==nil
      b[[j,i]] = 0
    end
    if (b[[i,j]]+b[[j,i]] > 0)
      print "#{i},#{j},#{b[[i,j]]},#{b[[j,i]]}\n"
    end
  end
end
