## ESPN 2015 Brackets and Imputed Power Rankings

Uncompress brackets archive:

gzip -d csv/espn-brackets.csv.gz

Generate game picks from brackets:

./brackets-games.rb

Generate game counts from game outcomes:

./brackets-counts.sh

Generate game binomial outcome counts from game counts:

./brackets-binomial.rb > csv/espn-outcomes.csv
