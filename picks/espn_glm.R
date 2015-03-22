
games <- read.csv("outcomes.csv", header=TRUE)
teams <- read.csv("teams.csv", header=TRUE)

games$team <- as.factor(games$team)
games$opponent <- as.factor(games$opponent)

games <- rbind(games, data.frame(team=games$opponent, opponent=games$team, won=games$lost, lost=games$won))

head(games)

dim(games)

fit <- glm(cbind(won,lost) ~ team+opponent, family=binomial(logit), data=games)

fit
summary(fit)
exp(coef(fit))

