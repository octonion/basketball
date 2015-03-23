library(BradleyTerry2)

games <- read.csv("outcomes.csv", header=TRUE)
teams <- read.csv("teams.csv", header=TRUE)

games$team <- as.factor(games$team)
games$opponent <- as.factor(games$opponent)

head(games)

dim(games)

fit <- BTm(cbind(won, lost), team, opponent, data = games)

espn <- as.data.frame(BTabilities(fit))
espn$id <- rownames(espn)

ranks <- merge(teams, espn)
ranks <- ranks[with(ranks, order(-ability)), ]

ranks <- subset(ranks, TRUE, select=c(k_id,name_long,ability))
colnames(ranks)[1] <- "id"
colnames(ranks)[2] <- "team"

ranks$strength <- exp(ranks$ability)

ranks <- cbind(rank=rank(-ranks$ability), ranks)

ranks
write.csv(ranks, file="ranks.csv", row.names=FALSE)
