
ranks <- read.csv("selection_rankings.csv", header=TRUE)

cor.test(ranks$ncaa_order, ranks$octonion_order, method="kendall", exact=TRUE)
