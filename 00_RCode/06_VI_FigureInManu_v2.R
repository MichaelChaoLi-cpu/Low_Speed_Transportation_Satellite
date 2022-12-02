# Author: M.L.

# end

library(ggplot2)
library(dplyr)
library(tidyverse)
library(grid)
library(gridExtra)
library("viridisLite")
library("viridis") 
library(sp)
library(moments)
library(ggpubr)

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
GWPR.residuals.df$y <- GWPR.residuals.df$y / 1000000
GWPR.residuals.df$yhat <- GWPR.residuals.df$yhat / 1000000
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
GWPR.residuals.df$Density <- (GWPR.residuals.df$Density + 1) %>% log()
(gwpr.cv <- ggplot(GWPR.residuals.df) +
    geom_point(aes(x = y, y = yhat, color = Density)) +
    scale_color_viridis(name = "Density (Log)") + 
    scale_x_continuous(name = "Measured Low-Speed Transportation Column (Million Capita/grid month)") +
    scale_y_continuous(name = "Predicted Low-Speed Transportation Column (Million Capita/grid month)") +
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



formula <- lowSpeedDensity ~ NTL + NDVI + Temperature + prevalance + emergence
load("04_Data/00_datasetUsed.RData")
load("04_Data/00_points_mesh.in.GT.RData")
data.in.GT <- points_mesh.in.GT@data %>% 
  dplyr::select(GridID, PrefID)
dataset_used <- left_join(dataset_used, data.in.GT)
dataset_used <- dataset_used %>% filter(!is.na(PrefID))
rm(data.in.GT)
points_mesh.in.Tokyo <- points_mesh.in.GT@data
points_mesh.in.Tokyo <- points_mesh.in.Tokyo %>%
  filter(PrefID == "13")
dataset_used.Tokyo <- left_join(points_mesh.in.Tokyo %>% dplyr::select(GridID),
                                dataset_used)
#-------------descriptive statistics--------------
Mean <- round(mean(dataset_used.Tokyo$lowSpeedDensity), 2)
SD <- round(sd(dataset_used.Tokyo$lowSpeedDensity), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.65,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("a",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(a <- ggplot(dataset_used.Tokyo) +
    aes(x = lowSpeedDensity) +
    xlim(0, 1e+06) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$lowSpeedDensity),
                              sd = sd(dataset_used.Tokyo$lowSpeedDensity)),
                  col = 'red', size = 2) +
    xlab("Low-Speed Transportation Column") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$NTL), 2)
SD <- round(sd(dataset_used.Tokyo$NTL), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.71,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("b",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(b <- ggplot(dataset_used.Tokyo) +
    aes(x = NTL) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$NTL),
                              sd = sd(dataset_used.Tokyo$NTL)),
                  col = 'red', size = 2) +
    xlim(0, 50) +
    xlab("NTL") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$NDVI), 2)
SD <- round(sd(dataset_used.Tokyo$NDVI), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("c",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(c <- ggplot(dataset_used.Tokyo) +
    aes(x = NDVI) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$NDVI),
                              sd = sd(dataset_used.Tokyo$NDVI)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("NDVI (%)") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$Temperature), 2)
SD <- round(sd(dataset_used.Tokyo$Temperature), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.50,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("d",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(d <- ggplot(dataset_used.Tokyo) +
    aes(x = Temperature) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$Temperature),
                              sd = sd(dataset_used.Tokyo$Temperature)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("Temperature (Celsius Degree)") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$prevalance), 2)
SD <- round(sd(dataset_used.Tokyo$prevalance), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.75,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("e",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(e <- ggplot(dataset_used.Tokyo) +
    aes(x = prevalance) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$prevalance),
                              sd = sd(dataset_used.Tokyo$prevalance)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("COVID-19 Prevalence (Case/1000 Capita)") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$emergence), 2)
SD <- round(sd(dataset_used.Tokyo$emergence), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.75,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("f",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(f <- ggplot(dataset_used.Tokyo) +
    aes(x = emergence) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$emergence),
                              sd = sd(dataset_used.Tokyo$emergence)),
                  col = 'red', size = 2) +
    xlim(-0.1, 0.8) +
    xlab("Lockdown Ratio") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))


jpeg(file="06_Figure/descriptive_stat.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
grid.arrange(a, b, c,
             d, e, f,
             nrow = 2)
dev.off()
#-------------descriptive statistics--------------

#-------------trends of XY------------------------
dataset_used.Tokyo$lowSpeedDensity <- dataset_used.Tokyo$lowSpeedDensity / 1000 / 1000 
(plot1 <- ggscatter(dataset_used.Tokyo, x = "NTL", y = "lowSpeedDensity", size = 1,
                    add = "reg.line", conf.int = TRUE,
                    cor.coef = F, cor.method = "pearson",
                    xlab = "NTL", ylab = "Low-Speed Transportation Column\n(Million Capita/grid month)",           
                    add.params = list(color = "blue", fill = "lightskyblue1"),
                    color = "grey76", shape = 21, xlim = c(0, 600), ylim = c(0, 6)
                    ) +
  stat_cor( p.accuracy = 0.01, r.accuracy = 0.01, label.x.npc = "left", label.y.npc = 0.96) +
  annotate("text", x = 0, y = 6, label = 'bold("a")', parse = TRUE, size = 5)
)


(plot2 <- ggscatter(dataset_used.Tokyo, x = "NDVI", y = "lowSpeedDensity", size = 1,
                    add = "reg.line", conf.int = TRUE,
                    cor.coef = F, cor.method = "pearson",
                    xlab = "NDVI (%)", ylab = "Low-Speed Transportation Column\n(Million Capita/grid month)",
                    add.params = list(color = "blue", fill = "lightskyblue1"),
                    color = "grey76", shape = 21, ylim = c(0, 6)
                    ) +
    stat_cor( p.accuracy = 0.01, r.accuracy = 0.01, label.x.npc = "left", label.y.npc = 0.96) +
    annotate("text", x = 0, y = 6, label = 'bold("b")', parse = TRUE, size = 5)
)

(plot3 <- ggscatter(dataset_used.Tokyo, x = "Temperature", y = "lowSpeedDensity", size = 1,
                    add = "reg.line", conf.int = TRUE,
                    cor.coef = F, cor.method = "pearson",
                    xlab = "Temperature (Celsius Degree)", ylab = "Low-Speed Transportation Column\n(Million Capita/grid month)",
                    add.params = list(color = "blue", fill = "lightskyblue1"),
                    color = "grey76", shape = 21, ylim = c(0, 6)
                    ) +
    stat_cor( p.accuracy = 0.01, r.accuracy = 0.01, label.x.npc = "left", label.y.npc = 0.96)+
    annotate("text", x = 0, y = 6, label = 'bold("c")', parse = TRUE, size = 5)
)

(plot4 <- ggscatter(dataset_used.Tokyo, x = "prevalance", y = "lowSpeedDensity", size = 1,
                    add = "reg.line", conf.int = TRUE,
                    cor.coef = F, cor.method = "pearson",
                    xlab = "COVID-19 Prevalence (Case/1000 Capita)", ylab = "Low-Speed Transportation Column\n(Million Capita/grid month)",
                    add.params = list(color = "blue", fill = "lightskyblue1"),
                    color = "grey76", shape = 21, ylim = c(0, 6)
                    ) +
    stat_cor( p.accuracy = 0.01, r.accuracy = 0.01, label.x.npc = "left", label.y.npc = 0.96) +
    annotate("text", x = 0, y = 6, label = 'bold("d")', parse = TRUE, size = 5)
)

(plot5 <- ggscatter(dataset_used.Tokyo, x = "emergence", y = "lowSpeedDensity", size = 1,
                    add = "reg.line", conf.int = TRUE,
                    cor.coef = F, cor.method = "pearson",
                    xlab = "Lockdown Ratio", ylab = "Low-Speed Transportation Column\n(Million Capita/grid month)",
                    add.params = list(color = "blue", fill = "lightskyblue1"),
                    color = "grey76", shape = 21, ylim = c(0, 6)
                    ) +
    stat_cor( p.accuracy = 0.01, r.accuracy = 0.01, label.x.npc = "left", label.y.npc = 0.96) +
    annotate("text", x = 0, y = 6, label = 'bold("e")', parse = TRUE, size = 5)
)


jpeg(file="06_Figure/cor_line1.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
grid.arrange(plot1, plot2, plot3, 
             plot4, plot5, 
             nrow = 2)
dev.off()
#-------------trends of XY------------------------



dataset_used.Tokyo$lowSpeedDensity <- dataset_used.Tokyo$lowSpeedDensity * 1000 * 1000 
formula <- lowSpeedDensity ~ NTL + NDVI + Temperature + prevalance + emergence
usedDataset.tranformed <- dataset_used.Tokyo %>% dplyr::select(GridID, all.vars(formula))
usedDataset.tranformed.mean <- usedDataset.tranformed %>%
  aggregate(by = list(usedDataset.tranformed$GridID), FUN = mean)
usedDataset.tranformed.mean$GridID <- usedDataset.tranformed.mean$Group.1 
usedDataset.tranformed.mean <- usedDataset.tranformed.mean %>% dplyr::select(-Group.1)
colnames(usedDataset.tranformed.mean) <- paste0(colnames(usedDataset.tranformed.mean), "_m")
colnames(usedDataset.tranformed.mean)[1] <- "GridID"
usedDataset.tranformed <- left_join(usedDataset.tranformed, usedDataset.tranformed.mean, by = "GridID")
usedDataset.tranformed <- usedDataset.tranformed %>%
  mutate(lowSpeedDensity_t = lowSpeedDensity - lowSpeedDensity_m,
         NTL_t = NTL - NTL_m,
         NDVI_t = NDVI - NDVI_m,
         Temperature_t = Temperature - Temperature_m,
         prevalance_t = prevalance - prevalance_m,
         emergence_t = emergence - emergence_m)

#-------------descriptive statistics--------------
Mean <- round(mean(usedDataset.tranformed$lowSpeedDensity_t), 2)
SD <- round(sd(usedDataset.tranformed$lowSpeedDensity_t), 2)
N = nrow(usedDataset.tranformed)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.65,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("a",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(a <- ggplot(usedDataset.tranformed) +
    aes(x = lowSpeedDensity_t) +
    xlim(-5e+05, 5e+05) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(usedDataset.tranformed$lowSpeedDensity_t),
                              sd = sd(usedDataset.tranformed$lowSpeedDensity_t)),
                  col = 'red', size = 2) +
    xlab("Low-Speed Transportation Column") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(usedDataset.tranformed$NTL_t), 2)
SD <- round(sd(usedDataset.tranformed$NTL_t), 2)
N = nrow(usedDataset.tranformed)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.72,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("b",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(b <- ggplot(usedDataset.tranformed) +
    aes(x = NTL_t) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(usedDataset.tranformed$NTL_t),
                              sd = sd(usedDataset.tranformed$NTL_t)),
                  col = 'red', size = 2) +
    xlim(-25, 25) +
    xlab("NTL") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(usedDataset.tranformed$NDVI_t), 2)
SD <- round(sd(usedDataset.tranformed$NDVI_t), 2)
N = nrow(usedDataset.tranformed)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.75,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("c",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(c <- ggplot(usedDataset.tranformed) +
    aes(x = NDVI_t) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(usedDataset.tranformed$NDVI_t),
                              sd = sd(usedDataset.tranformed$NDVI_t)),
                  col = 'red', size = 2) +
    xlim(-15, 15) +
    xlab("NDVI (%)") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(usedDataset.tranformed$Temperature_t), 2)
SD <- round(sd(usedDataset.tranformed$Temperature_t), 2)
N = nrow(usedDataset.tranformed)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.75,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("d",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(d <- ggplot(usedDataset.tranformed) +
    aes(x = Temperature_t) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(usedDataset.tranformed$Temperature_t),
                              sd = sd(usedDataset.tranformed$Temperature_t)),
                  col = 'red', size = 2) +
    xlim(-10, 10) +
    xlab("Temperature (Celsius Degree)") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(usedDataset.tranformed$prevalance_t), 2)
SD <- round(sd(usedDataset.tranformed$prevalance_t), 2)
N = nrow(usedDataset.tranformed)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.75,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("e",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(e <- ggplot(usedDataset.tranformed) +
    aes(x = prevalance_t) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(usedDataset.tranformed$prevalance_t),
                              sd = sd(usedDataset.tranformed$prevalance_t)),
                  col = 'red', size = 2) +
    xlim(-0.05, 0.05) +
    xlab("COVID-19 Prevalence (Case/1000 Capita)") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(usedDataset.tranformed$emergence_t), 2)
SD <- round(sd(usedDataset.tranformed$emergence_t), 2)
N = nrow(usedDataset.tranformed)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.75,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("f",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(f <- ggplot(usedDataset.tranformed) +
    aes(x = emergence_t) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(usedDataset.tranformed$emergence_t),
                              sd = sd(usedDataset.tranformed$emergence_t)),
                  col = 'red', size = 2) +
    xlim(-0.4, 0.4) +
    xlab("Lockdown Ratio") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

jpeg(file="06_Figure/descriptive_stat_transform.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
grid.arrange(a, b, c,
             d, e, f,
             nrow = 2)
dev.off()
#-------------descriptive statistics--------------

#### check skewness

skewness(usedDataset.tranformed$lowSpeedDensity)
skewness(usedDataset.tranformed$NTL)
skewness(usedDataset.tranformed$NDVI)
skewness(usedDataset.tranformed$Temperature)
skewness(usedDataset.tranformed$prevalance)
skewness(usedDataset.tranformed$emergence)

skewness(usedDataset.tranformed$lowSpeedDensity_t)
skewness(usedDataset.tranformed$NTL_t)
skewness(usedDataset.tranformed$NDVI_t)
skewness(usedDataset.tranformed$Temperature_t)
skewness(usedDataset.tranformed$prevalance_t)
skewness(usedDataset.tranformed$emergence_t)

GWPR.FEM.bandwidth.temp <-
  c(169335520, 246166362, 54478341, 106825361, 170485959, 52470546, 98328164, 119094439, # 0.02
    68031382, 96273843, 70460731, 76411967, 82523261, 68907767, 79838406, 83369647, # 0.04
    78814983, 83069440, 94671040, 92346531, 93639655, 97400574, 96500364, 105328915, # 0.06
    103172993, 108376984, 108376984, 116806274, 122287170, 128032493, 128669532, 135547573, # 0.08
    133396281, 138741250, 147216220, 143733511, 146815411, 152955409, 151361974, 157777848, # 0.10
    154885725, 161805554, 163301140, 164404284, 168440166, 173955825, 175735641, 179891492, # 0.12
    184164716, 189121961, 192260140, 195698420, 199618679, 205245167, 207852793, 210596774, # 0.14
    215415933, 216794229, 220253753, 223309878, 225327396, 228726201, 228819643, 231412879, # 0.16
    235055216, 235682452, 237982507, 240489300, 241485007, 243588578, 242300083, 242384025, # 0.18
    241220978, 238628371, 238322413, 235883249, 233084975, 230788726, 231062511 # 0.1975
  )
step <- seq(0.0025, 0.1975, 0.0025)
bw.df <- cbind(GWPR.FEM.bandwidth.temp, step) %>% as.data.frame()

## 
bw.plot <- ggplot(bw.df, aes(x = step, y = GWPR.FEM.bandwidth.temp)) +
  geom_point() + 
  annotate("segment", xend = 0.016, x = 0.05, yend = 52470546, y = 50000000,
           colour = "red", size = 1.5, arrow = arrow()) +
  annotate("text", x = 0.06, y = 48000000, label = "Optimal Bandwidth: 0.015") +
  scale_x_continuous(name = "Fixed Distance Bandwidth (Arc Degree)") +
  scale_y_continuous(name = "Mean Square Prediction Error") +
  theme_bw()
jpeg(file="06_Figure/bwselection.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
bw.plot
dev.off()
