# Author: M.L.

# Visualization

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

dataset_used.Tokyo <- read.csv('04_Data/98_DatasetWithNoah.csv')
dataset_used.Tokyo <- dataset_used.Tokyo %>% na.omit()
#-------------descriptive statistics--------------
Mean <- round(mean(dataset_used.Tokyo$lowSpeedDensity), 2)
SD <- round(sd(dataset_used.Tokyo$lowSpeedDensity), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.45,  y = 0.90, hjust = 0,
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

Mean <- round(mean(dataset_used.Tokyo$tair), 2)
SD <- round(sd(dataset_used.Tokyo$tair), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("b",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(b <- ggplot(dataset_used.Tokyo) +
    aes(x = tair) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$tair),
                              sd = sd(dataset_used.Tokyo$tair)),
                  col = 'red', size = 2) +
    #xlim(0, 50) +
    xlab("Temperature") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$psurf), 2)
SD <- round(sd(dataset_used.Tokyo$psurf), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.58,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("c",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(c <- ggplot(dataset_used.Tokyo) +
    aes(x = psurf) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$psurf),
                              sd = sd(dataset_used.Tokyo$psurf)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("Air Pressure") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$qair), 2)
SD <- round(sd(dataset_used.Tokyo$qair), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("d",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(d <- ggplot(dataset_used.Tokyo) +
    aes(x = qair) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$qair),
                              sd = sd(dataset_used.Tokyo$qair)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("humidity") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$wind), 2)
SD <- round(sd(dataset_used.Tokyo$wind), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("e",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(e <- ggplot(dataset_used.Tokyo) +
    aes(x = wind) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$wind),
                              sd = sd(dataset_used.Tokyo$wind)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("Wind Speed") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$rainf), 2)
SD <- round(sd(dataset_used.Tokyo$rainf), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("f",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(f <- ggplot(dataset_used.Tokyo) +
    aes(x = rainf) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$rainf),
                              sd = sd(dataset_used.Tokyo$rainf)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("Precipitation") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$PBLH), 2)
SD <- round(sd(dataset_used.Tokyo$PBLH), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("g",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(g <- ggplot(dataset_used.Tokyo) +
    aes(x = PBLH) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$PBLH),
                              sd = sd(dataset_used.Tokyo$PBLH)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("PBLH") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$NTL), 2)
SD <- round(sd(dataset_used.Tokyo$NTL), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("h",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(h <- ggplot(dataset_used.Tokyo) +
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
grob_add <- grobTree(textGrob("i",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(i <- ggplot(dataset_used.Tokyo) +
    aes(x = NDVI) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$NDVI),
                              sd = sd(dataset_used.Tokyo$NDVI)),
                  col = 'red', size = 2) +
    #xlim(0, 50) +
    xlab("NDVI") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))


Mean <- round(mean(dataset_used.Tokyo$prevalance), 2)
SD <- round(sd(dataset_used.Tokyo$prevalance), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("j",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(j <- ggplot(dataset_used.Tokyo) +
    aes(x = prevalance) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$prevalance),
                              sd = sd(dataset_used.Tokyo$prevalance)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("COVID-19 Prevalence") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$mortality), 2)
SD <- round(sd(dataset_used.Tokyo$mortality), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("k",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(k <- ggplot(dataset_used.Tokyo) +
    aes(x = mortality) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$mortality),
                              sd = sd(dataset_used.Tokyo$mortality)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("COVID-19 Mortality") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$emergence), 2)
SD <- round(sd(dataset_used.Tokyo$emergence), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("l",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(l <- ggplot(dataset_used.Tokyo) +
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


jpeg(file="11_Figure0618/descriptive_stat.jpeg", width = 210, height = 297, units = "mm", quality = 300, res = 300)
grid.arrange(a, b, c,
             d, e, f,
             g, h, i,
             j, k, l,
             nrow = 4)
dev.off()
#-------------descriptive statistics--------------

dataset_Xshap <- read.csv('03_Results/03_mergedXSHAPStdize_noah_withoutAP.csv')
dataset_used.Tokyo <- dataset_Xshap %>% na.omit()
#-------------descriptive statistics--------------
Mean <- round(mean(dataset_used.Tokyo$lowSpeedDensity), 2)
SD <- round(sd(dataset_used.Tokyo$lowSpeedDensity), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("a",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(a <- ggplot(dataset_used.Tokyo) +
    aes(x = lowSpeedDensity) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$lowSpeedDensity),
                              sd = sd(dataset_used.Tokyo$lowSpeedDensity)),
                  col = 'red', size = 2) +
    xlab("Low-Speed Transportation Column") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$tair), 2)
SD <- round(sd(dataset_used.Tokyo$tair), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("b",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(b <- ggplot(dataset_used.Tokyo) +
    aes(x = tair) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$tair),
                              sd = sd(dataset_used.Tokyo$tair)),
                  col = 'red', size = 2) +
    #xlim(0, 50) +
    xlab("Temperature") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$psurf), 2)
SD <- round(sd(dataset_used.Tokyo$psurf), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("c",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(c <- ggplot(dataset_used.Tokyo) +
    aes(x = psurf) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$psurf),
                              sd = sd(dataset_used.Tokyo$psurf)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("Air Pressure") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$qair), 2)
SD <- round(sd(dataset_used.Tokyo$qair), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("d",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(d <- ggplot(dataset_used.Tokyo) +
    aes(x = qair) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$qair),
                              sd = sd(dataset_used.Tokyo$qair)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("humidity") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$wind), 2)
SD <- round(sd(dataset_used.Tokyo$wind), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("e",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(e <- ggplot(dataset_used.Tokyo) +
    aes(x = wind) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$wind),
                              sd = sd(dataset_used.Tokyo$wind)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("Wind Speed") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$rainf), 2)
SD <- round(sd(dataset_used.Tokyo$rainf), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("f",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(f <- ggplot(dataset_used.Tokyo) +
    aes(x = rainf) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$rainf),
                              sd = sd(dataset_used.Tokyo$rainf)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("Precipitation") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$PBLH), 2)
SD <- round(sd(dataset_used.Tokyo$PBLH), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("g",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(g <- ggplot(dataset_used.Tokyo) +
    aes(x = PBLH) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$PBLH),
                              sd = sd(dataset_used.Tokyo$PBLH)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("PBLH") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$NTL), 2)
SD <- round(sd(dataset_used.Tokyo$NTL), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("h",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(h <- ggplot(dataset_used.Tokyo) +
    aes(x = NTL) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$NTL),
                              sd = sd(dataset_used.Tokyo$NTL)),
                  col = 'red', size = 2) +
    #xlim(0, 50) +
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
grob_add <- grobTree(textGrob("i",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(i <- ggplot(dataset_used.Tokyo) +
    aes(x = NDVI) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$NDVI),
                              sd = sd(dataset_used.Tokyo$NDVI)),
                  col = 'red', size = 2) +
    #xlim(0, 50) +
    xlab("NDVI") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))


Mean <- round(mean(dataset_used.Tokyo$prevalance), 2)
SD <- round(sd(dataset_used.Tokyo$prevalance), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("j",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(j <- ggplot(dataset_used.Tokyo) +
    aes(x = prevalance) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$prevalance),
                              sd = sd(dataset_used.Tokyo$prevalance)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("COVID-19 Prevalence") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$mortality), 2)
SD <- round(sd(dataset_used.Tokyo$mortality), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("k",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(k <- ggplot(dataset_used.Tokyo) +
    aes(x = mortality) +
    geom_histogram(aes(y = ..density..), colour = "black", fill = "white") +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(dataset_used.Tokyo$mortality),
                              sd = sd(dataset_used.Tokyo$mortality)),
                  col = 'red', size = 2) +
    #xlim(0, 20) +
    xlab("COVID-19 Mortality") + 
    ylab("Density") +
    annotation_custom(grob) +
    annotation_custom(grob_add))

Mean <- round(mean(dataset_used.Tokyo$emergence), 2)
SD <- round(sd(dataset_used.Tokyo$emergence), 2)
N = nrow(dataset_used.Tokyo)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.61,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 8)))
grob_add <- grobTree(textGrob("l",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(l <- ggplot(dataset_used.Tokyo) +
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


jpeg(file="11_Figure0618/descriptive_stat_transfomed.jpeg", width = 210, height = 297, units = "mm", quality = 300, res = 300)
grid.arrange(a, b, c,
             d, e, f,
             g, h, i,
             j, k, l,
             nrow = 4)
dev.off()
#-------------descriptive statistics--------------

