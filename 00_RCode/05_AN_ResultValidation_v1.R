# Author: M.L.

# end

library(tidyverse)
library(dplyr)

load("03_Results/GWPR_FEM_CV_F_result_lowSpeedDensity_0015.Rdata")
year.judgement.score <- function(residual.dataset){
  r2 <- 1 - sum( (residual.dataset$resid)^2 ) /
    sum((residual.dataset$y - mean(residual.dataset$y))^2)
  rmse <- sqrt(sum(residual.dataset$resid^2)/nrow(residual.dataset))
  mae <- mean(abs(residual.dataset$resid))
  cor.score <- cor.test(residual.dataset$y, residual.dataset$yhat)
  cor.score <- cor.score$estimate %>% as.numeric()
  reg <- lm(yhat ~ y, data = residual.dataset )
  coeff = coefficients(reg)
  N <- nrow(residual.dataset)
  year <- residual.dataset$time[1]
  line.result <- c(year, N, r2, rmse, mae, cor.score, coeff[2], coeff[1])
  return(line.result)
}

### RSME MAE r coefficient
GWPR.residuals.df <- GWPR.FEM.CV.F.result$GWPR.residuals

lm(y ~ yhat, GWPR.residuals.df) %>% summary()
(sum( (GWPR.residuals.df$resid)^2 ) / length(GWPR.residuals.df$resid)) %>% sqrt() #RSME
mean( abs( (GWPR.residuals.df$resid) ) ) #MAE
cor.test(GWPR.residuals.df$y, GWPR.residuals.df$yhat) # r
mean(GWPR.residuals.df$y)


##### temporal validation
### get judgement score
residual.GWPR <- GWPR.FEM.CV.F.result$GWPR.residuals 
rmse <- sqrt(sum(residual.GWPR$resid^2)/nrow(residual.GWPR))
mae <- mean(abs(residual.GWPR$resid))

line.201901 <- year.judgement.score(residual.GWPR %>% filter(time == 201901))
line.201902 <- year.judgement.score(residual.GWPR %>% filter(time == 201902))
line.201903 <- year.judgement.score(residual.GWPR %>% filter(time == 201903))
line.201904 <- year.judgement.score(residual.GWPR %>% filter(time == 201904))
line.201905 <- year.judgement.score(residual.GWPR %>% filter(time == 201905))
line.201906 <- year.judgement.score(residual.GWPR %>% filter(time == 201906))
line.201907 <- year.judgement.score(residual.GWPR %>% filter(time == 201907))
line.201908 <- year.judgement.score(residual.GWPR %>% filter(time == 201908))
line.201909 <- year.judgement.score(residual.GWPR %>% filter(time == 201909))
line.201910 <- year.judgement.score(residual.GWPR %>% filter(time == 201910))
line.201911 <- year.judgement.score(residual.GWPR %>% filter(time == 201911))
line.201912 <- year.judgement.score(residual.GWPR %>% filter(time == 201912))

line.202001 <- year.judgement.score(residual.GWPR %>% filter(time == 202001))
line.202002 <- year.judgement.score(residual.GWPR %>% filter(time == 202002))
line.202003 <- year.judgement.score(residual.GWPR %>% filter(time == 202003))
line.202004 <- year.judgement.score(residual.GWPR %>% filter(time == 202004))
line.202005 <- year.judgement.score(residual.GWPR %>% filter(time == 202005))
line.202006 <- year.judgement.score(residual.GWPR %>% filter(time == 202006))
line.202007 <- year.judgement.score(residual.GWPR %>% filter(time == 202007))
line.202008 <- year.judgement.score(residual.GWPR %>% filter(time == 202008))
line.202009 <- year.judgement.score(residual.GWPR %>% filter(time == 202009))
line.202010 <- year.judgement.score(residual.GWPR %>% filter(time == 202010))
line.202011 <- year.judgement.score(residual.GWPR %>% filter(time == 202011))
line.202012 <- year.judgement.score(residual.GWPR %>% filter(time == 202012))
line.total <- year.judgement.score(residual.GWPR)

judgement.score <- rbind(line.201901, line.201902, line.201903, line.201904,
                         line.201905, line.201906, line.201907, line.201908,
                         line.201909, line.201910, line.201911, line.201912,
                         line.202001, line.202002, line.202003, line.202004,
                         line.202005, line.202006, line.202007, line.202008,
                         line.202009, line.202010, line.202011, line.202012,
                         line.total) %>% as.data.frame()
colnames(judgement.score) <- c("Time", "N", "R2", "RMSE", "MAE", "r", "Slope", "Intercept")
write.csv(judgement.score, file = "09_Tables/judgement.score.csv")

