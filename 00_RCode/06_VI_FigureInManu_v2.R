# Author: M.L.

# end

library(ggplot2)
library(dplyr)
library(tidyverse)
library(grid)
library(gridExtra)
library("viridisLite")
library("viridis") 

get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}

set.seed(1)
dat <- data.frame(
  x = c(
    rnorm(1e4, mean = 0, sd = 0.1),
    rnorm(1e3, mean = 0, sd = 0.1)
  ),
  y = c(
    rnorm(1e4, mean = 0, sd = 0.1),
    rnorm(1e3, mean = 0.1, sd = 0.2)
  )
)


load("03_Results/GWPR_FEM_CV_F_result_lowSpeedDensity_0015.Rdata")
GWPR.residuals.df <- GWPR.FEM.CV.F.result$GWPR.residuals
#---------------------GWPR-------------------------------------
GWPR.residuals.df$Density <- get_density(GWPR.residuals.df$y, GWPR.residuals.df$yhat, n = 500)
reg <- lm(yhat ~ y, data = GWPR.residuals.df)
coeff = coefficients(reg)
eq = paste0("y = ", round(coeff[2],3), "x + ", round(coeff[1],3))
grob <- grobTree(textGrob(eq,
                          x = 0.05,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 12)))
corre <- cor(GWPR.residuals.df$y, GWPR.residuals.df$yhat)
corr.text <- paste0("r = ", round(corre,4))
grob.corr <- grobTree(textGrob(corr.text,
                               x = 0.05,  y = 0.85, hjust = 0,
                               gp = gpar(col = "black", fontsize = 12)))
N <- length(GWPR.residuals.df$y)
N.text <- paste0("N = ", N)
grob.N <- grobTree(textGrob(N.text,
                            x = 0.05,  y = 0.80, hjust = 0,
                            gp = gpar(col = "black", fontsize = 12)))
grob_add <- grobTree(textGrob("GWPR",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(gwpr.cv <- ggplot(GWPR.residuals.df) +
    geom_point(aes(x = y, y = yhat, color = Density)) +
    scale_color_viridis() + 
    scale_x_continuous(name = "Measured Low-Speed Transportation Column") +
    scale_y_continuous(name = "Predicted Low-Speed Transportation Column") +
    geom_abline(intercept = 0, slope = 1, color="red", 
                linetype = "dashed", size = 0.5) + 
    geom_abline(intercept = coeff[1], slope = coeff[2], color="blue", 
                size= 0.5) + 
    annotation_custom(grob) + 
    annotation_custom(grob.corr) +
    annotation_custom(grob.N) +
    annotation_custom(grob_add)+
    theme_bw())

jpeg(file="06_Figure/gwpr.cv.jpeg", width = 210, height = 210, units = "mm", quality = 300, res = 300)
gwpr.cv 
dev.off()