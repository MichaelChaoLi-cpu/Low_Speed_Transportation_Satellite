# Author: M.L.

# end

load("03_Results/GWPR_FEM_CV_F_result_lowSpeedDensity_0015.Rdata")


### RSME MAE r coefficient
GWPR.residuals.df <- GWPR.FEM.CV.F.result$GWPR.residuals

lm(y ~ yhat, GWPR.residuals.df) %>% summary()
(sum( (GWPR.residuals.df$resid)^2 ) / length(GWPR.residuals.df$resid)) %>% sqrt() #RSME
mean( abs( (GWPR.residuals.df$resid) ) ) #MAE
cor.test(GWPR.residuals.df$y, GWPR.residuals.df$yhat) # r
mean(GWPR.residuals.df$y)


