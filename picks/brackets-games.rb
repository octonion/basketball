#!/usr/bin/env ruby

require 'csv'

brackets = CSV.read("csv/espn-brackets.csv")
games = CSV.open("csv/espn-games.csv","w")

done = 0

brackets.each do |bracket|

  round_previous = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,56,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64]

  id = bracket[0].to_i
  picks = bracket[1].split("|").map(&:to_i)

  n = round_previous.length
  while (n>1) do
    n = n/2
    round_next = picks.slice(0, n)
    picks = picks.slice(n, picks.length)

    for i in 0..n-1 do
      winner = round_next[i]
      teams = [round_previous[2*i], round_previous[2*i+1]]
      if (winner == teams[0])
        #print "#{winner} beat #{teams[1]}\n"
        games << [winner,teams[1]]
      else
        #print "#{winner} beat #{teams[0]}\n"
        games << [winner,teams[0]]
      end
    end
    round_previous = round_next
  end
  done += 1
  if (done%10000)==0
    print "brackets done - #{done}\n"
  end

end
print "total brackets - #{done}\n"
games.close
