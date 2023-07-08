# Author: M.L.

# Visualization

# end

library(dplyr)
library(tidyverse)
library(tmap)
library(rgdal)
library(ggplot2)
library(grid)
library(gridExtra)
library(sf)
library(sp)
library(ggspatial) # scale bars and north arrows
library(ggmap)
library(cowplot)
library(ggrepel)
library(plotrix)

key <- readLines("./privateKeyGoogle.txt")
register_google(key = key)

setwd("./04_Data/shp/")
shape_Japan_pref <- readOGR(dsn = ".", layer = "jpn_admbnda_adm1_2019")
shape_Japan_pref@data$tokyo <- 0
shape_Japan_pref@data <- shape_Japan_pref@data %>%
  mutate(tokyo = ifelse(ADM1_PCODE=="JP13", 1, 0))
shape_Japan_pref@data$tokyo <- shape_Japan_pref@data$tokyo %>% as.factor()
shape_Japan_pref <- st_as_sf(shape_Japan_pref)
shape_Japan_pref <- st_transform(shape_Japan_pref, crs = 4326)

df <- data.frame(x = c(139.839478), y = c(35.652832), name = c("Tokyo"))
plot.1 <- ggplot() +
  geom_sf(data = shape_Japan_pref, color = "grey65", aes(fill = tokyo), alpha = 1, size = 0.01,
          show.legend = FALSE) +
  scale_fill_manual(values = c("gray100", "red")) +
  geom_point(data = df, aes(x = x, y = y), color = "red") +
  geom_label_repel(data = df, aes(x = x, y = y,label = name),
                   box.padding   = 0.35, 
                   point.padding = 0.5,
                   segment.color = 'black', alpha = 0.7) +
  annotation_scale(location = "br", width_hint = 0.4) +
  annotation_north_arrow(location = "br", which_north = "true", 
                         pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank())
plot.1

shape_Japan_city <- readOGR(dsn = ".", layer = "jpn_admbnda_adm2_2019")
shape_Japan_city@data$tokyo <- 0
shape_Japan_city@data <- shape_Japan_city@data %>%
  mutate(tokyo = ifelse(ADM1_PCODE=="JP13", 1, 0))
shape_Japan_city@data$tokyo <- shape_Japan_city@data$tokyo %>% as.factor()
shape_Japan_city <- st_as_sf(shape_Japan_city)

tokyo_basemap <- get_map( c(left = 138.8, bottom = 35.3, right = 140, top = 36.1),
                          zoom = 10, maptype = 'terrain-background', source = 'stamen')
ggmap(tokyo_basemap)

plot.2 <- ggmap(tokyo_basemap) +
  geom_sf(data = shape_Japan_city, color = "grey65", aes(fill = tokyo), alpha = 0.4, size = 0.5,
          show.legend = FALSE, inherit.aes = FALSE) +
  scale_fill_manual(values = c("white", "red")) +
  annotation_scale(location = "bl", width_hint = 0.4) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +
  theme_bw() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        plot.margin = margin(t = 0.1, r = 0, b = 0, l = 0, unit = "cm")
  ) +
  scale_x_continuous(labels = function(x) paste0(x, "°"), limits = c(138.8, 140)) +
  scale_y_continuous(labels = function(x) paste0(x, "°"), limits = c(35.3, 36.1))
plot.2


locationWithMulti <- ggdraw() +
  draw_plot(plot.2, x = 0, y = 0, width = 1, height = 1) +
  draw_plot(plot.1, x = .66, y = .625, width = .25, height = .4) +
  draw_plot_label(label = c("A", "B"), size = 15,
                  x = c(0.87, 0.13), y = c(0.975, 0.98))
setwd("../../")

jpeg(file="11_Figure0618/locationWithMulti.jpeg", width = 280, height = 210, units = "mm", quality = 300, res = 300)
locationWithMulti
dev.off()


### plot mean value
df.ori <- read.csv('04_Data/98_DatasetWithNoah.csv')
df.ori <- df.ori %>% 
  dplyr::select("GridID", "lowSpeedDensity", 'x', 'y')
df.ori <- stats::aggregate(df.ori[,c("lowSpeedDensity", "x", "y")],
                           by = list(df.ori$GridID), mean)
df.ori <- df.ori %>% mutate(lowSpeedDensity = ifelse(lowSpeedDensity > 1000000, 1000000, lowSpeedDensity))

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
xy <- df.ori[,c(3,4)]
points_mesh <- SpatialPointsDataFrame(coords = xy, data = df.ori,
                                      proj4string = CRS(proj))
points_mesh <- points_mesh %>% st_as_sf()

pal <- colorRampPalette(c("blue","green","yellow","red"))
pal(20)

shape_Japan_city <- readOGR(dsn = "./04_Data/shp/", layer = "jpn_admbnda_adm2_2019")
shape_Japan_city@data$tokyo <- 0
shape_Japan_city@data <- shape_Japan_city@data %>%
  mutate(tokyo = ifelse(ADM1_PCODE=="JP13", 1, 0))
shape_Japan_city@data$tokyo <- shape_Japan_city@data$tokyo %>% as.factor()
shape_Japan_city <- st_as_sf(shape_Japan_city)
tokyo_boudary <- shape_Japan_pref %>% filter(ADM1_PCODE == "JP13")

(plot.x.01 <- ggplot() +
    geom_sf(data = points_mesh, aes(color = lowSpeedDensity), alpha = 0.8, size = 0.5) +
    scale_color_gradientn("Mean", colors = pal(20),
                          breaks = c(0, 250000, 500000, 750000, 1000000), 
                          labels = c("0", "250k", "500k", "750k", "1000k+")) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "black", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.3, 36.1) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank()
    ) +
    scale_x_continuous(labels = function(x) paste0(x, "°"), limits = c(138.8, 140)) +
    scale_y_continuous(labels = function(x) paste0(x, "°"), limits = c(35.3, 36.1))
)

jpeg(file="11_Figure0618/meanX.Coeff.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
plot.x.01
dev.off()


### plot GWPR result
shape_Japan_city <- readOGR(dsn = "./04_Data/shp/.", layer = "jpn_admbnda_adm2_2019")
shape_Japan_city@data$tokyo <- 0
shape_Japan_city@data <- shape_Japan_city@data %>%
  mutate(tokyo = ifelse(ADM1_PCODE=="JP13", 1, 0))
shape_Japan_city@data$tokyo <- shape_Japan_city@data$tokyo %>% as.factor()
shape_Japan_city <- st_as_sf(shape_Japan_city)

tokyo_boudary <- shape_Japan_city %>% filter(ADM1_PCODE == "JP13")

# tair
pal <- colorRampPalette(c("blue","green", "white", "yellow","red"))

GWPR.result.tair <- readRDS('12_Results0618/02.GWPR.result.tair.rds')
SDF.coef <- GWPR.result.tair$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(tair = ifelse(tair < -0.05, -0.05, tair),
         tair = ifelse(tair > 0.05, 0.05, tair)
  )
SDF.coef <- SDF.coef %>% 
  mutate(tair = ifelse(abs(tair_TVa) < 1.64, 0, tair)
  )

grob_add <- grobTree(textGrob("a",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 10)))
pal <- colorRampPalette(c("blue","green", "white", "yellow","red"))
(plot.tair.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = tair), alpha = 0.8, size = 0.5) +
    scale_color_gradientn(colors = pal(21), limits = c(-0.05, 0.05), name = "Temperature") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 8),
          axis.text.y = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.text = element_text(size = 6),
          legend.key.size = unit(0.5, "cm")
    )+
    annotation_custom(grob_add)
)

# psurf
GWPR.result.psurf <- readRDS('12_Results0618/02.GWPR.result.psurf.rds')
SDF.coef <- GWPR.result.psurf$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(psurf = ifelse(abs(psurf_TVa) < 1.64, 0, psurf)
  )
SDF.coef$psurf %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    psurf = ifelse(psurf > 0.15, 0.15, psurf),
    psurf = ifelse(psurf < 0.10, 0.10, psurf)
  )

grob_add <- grobTree(textGrob("b",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 10)))
pal <- colorRampPalette(c("white", "yellow","red"))
(plot.psurf.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = psurf), alpha = 0.8, size = 0.5) +
    scale_color_gradientn(colors = pal(21), limits = c(0.10, 0.15), name = "Air Pressure") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 8),
          axis.text.y = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.text = element_text(size = 6),
          legend.key.size = unit(0.5, "cm")
    )+
    annotation_custom(grob_add)
)

# qair
GWPR.result.qair <- readRDS('12_Results0618/02.GWPR.result.qair.rds')
SDF.coef <- GWPR.result.qair$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(qair = ifelse(abs(qair_TVa) < 1.64, 0, qair)
  )
SDF.coef$qair %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    qair = ifelse(qair > 0.15, 0.15, qair),
    qair = ifelse(qair < 0.05, 0.05, qair)
  )

grob_add <- grobTree(textGrob("c",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 10)))
pal <- colorRampPalette(c("white", "yellow","red"))
(plot.qair.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = qair), alpha = 0.8, size = 0.5) +
    scale_color_gradientn(colors = pal(21), limits = c(0.05, 0.15), name = "Humidity") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 8),
          axis.text.y = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.text = element_text(size = 6),
          legend.key.size = unit(0.5, "cm")
    )+
    annotation_custom(grob_add)
)

# wind
GWPR.result.wind <- readRDS('12_Results0618/02.GWPR.result.wind.rds')
SDF.coef <- GWPR.result.wind$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(wind = ifelse(abs(wind_TVa) < 1.64, 0, wind)
  )
SDF.coef$wind %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    wind = ifelse(wind > -0.02, 0.02, wind),
    wind = ifelse(wind < -0.12, -0.12, wind)
  )

grob_add <- grobTree(textGrob("d",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 10)))
pal <- colorRampPalette(c("blue","green", "white"))
(plot.wind.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = wind), alpha = 0.8, size = 0.5) +
    scale_color_gradientn(colors = pal(21), limits = c(-0.12, -0.02), name = "Wind Speed") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 8),
          axis.text.y = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.text = element_text(size = 6),
          legend.key.size = unit(0.5, "cm")
    )+
    annotation_custom(grob_add)
)

# rainf
GWPR.result.rainf <- readRDS('12_Results0618/02.GWPR.result.rainf.rds')
SDF.coef <- GWPR.result.rainf$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(rainf = ifelse(abs(rainf_TVa) < 1.64, 0, rainf)
  )
SDF.coef$rainf %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    rainf = ifelse(rainf > 0.02, 0.02, rainf),
    rainf = ifelse(rainf < -0.02, -0.02, rainf)
  )

grob_add <- grobTree(textGrob("e",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 10)))
pal <- colorRampPalette(c("blue","green", "white", "yellow","red"))
(plot.rainf.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = rainf), alpha = 0.8, size = 0.5) +
    scale_color_gradientn(colors = pal(21), limits = c(-0.02, 0.02), name = "Precipitation") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 8),
          axis.text.y = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.text = element_text(size = 6),
          legend.key.size = unit(0.5, "cm")
    )+
    annotation_custom(grob_add)
)

# NDVI
GWPR.result.NDVI <- readRDS('12_Results0618/02.GWPR.result.NDVI.rds')
SDF.coef <- GWPR.result.NDVI$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(NDVI = ifelse(abs(NDVI_TVa) < 1.64, 0, NDVI)
  )
SDF.coef$NDVI %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    NDVI = ifelse(NDVI > 0.05, 0.05, NDVI),
    NDVI = ifelse(NDVI < -0.05, -0.05, NDVI)
  )

grob_add <- grobTree(textGrob("f",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 10)))
pal <- colorRampPalette(c("blue","green", "white", "yellow","red"))
(plot.NDVI.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = NDVI), alpha = 0.8, size = 0.5) +
    scale_color_gradientn(colors = pal(21), limits = c(-0.05, 0.05), name = "NDVI") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 8),
          axis.text.y = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.text = element_text(size = 6),
          legend.key.size = unit(0.5, "cm")
    )+
    annotation_custom(grob_add)
)

# NTL
GWPR.result.NTL <- readRDS('12_Results0618/02.GWPR.result.NTL.rds')
SDF.coef <- GWPR.result.NTL$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(NTL = ifelse(abs(NTL_TVa) < 1.64, 0, NTL)
  )
SDF.coef$NTL %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    NTL = ifelse(NTL > 0.04, 0.04, NTL),
    NTL = ifelse(NTL < -0.04, -0.04, NTL)
  )
grob_add <- grobTree(textGrob("g",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 10)))
pal <- colorRampPalette(c("blue","green", "white", "yellow","red"))
(plot.NTL.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = NTL), alpha = 0.8, size = 0.5) +
    scale_color_gradientn(colors = pal(21), limits = c(-0.04, 0.04), name = "NTL") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 8),
          axis.text.y = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.text = element_text(size = 6),
          legend.key.size = unit(0.5, "cm")
    )+
    annotation_custom(grob_add)
)

# PBLH
GWPR.result.PBLH <- readRDS('12_Results0618/02.GWPR.result.PBLH.rds')
SDF.coef <- GWPR.result.PBLH$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(PBLH = ifelse(abs(PBLH_TVa) < 1.64, 0, PBLH)
  )
SDF.coef$PBLH %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    PBLH = ifelse(PBLH > 0.05, 0.05, PBLH),
    PBLH = ifelse(PBLH < -0.05, -0.05, PBLH)
  )

grob_add <- grobTree(textGrob("h",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 10)))
pal <- colorRampPalette(c("blue","green", "white", "yellow","red"))
(plot.PBLH.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = PBLH), alpha = 0.8, size = 0.5) +
    scale_color_gradientn(colors = pal(21), limits = c(-0.05, 0.05), name = "PBLH") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 8),
          axis.text.y = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.text = element_text(size = 6),
          legend.key.size = unit(0.5, "cm")
    )+
    annotation_custom(grob_add)
)

jpeg(file="11_Figure0618/GWPR.plot.jpeg", width = 240, height = 300, units = "mm", quality = 300, res = 300)
grid.arrange(plot.tair.01, plot.psurf.01,
             plot.qair.01, plot.wind.01,
             plot.rainf.01, plot.NDVI.01,
             plot.NTL.01, plot.PBLH.01,
             nrow = 4)
dev.off()



key <- readLines("./privateKeyGoogle.txt")
register_google(key = key)

tokyo_basemap <- get_map( c(left = 138.5, bottom = 35.3, right = 140.2, top = 36.1),
                           maptype = 'satellite', source = 'google')
ggmap(tokyo_basemap)

# rainf
GWPR.result.rainf <- readRDS('12_Results0618/02.GWPR.result.rainf.rds')
SDF.coef <- GWPR.result.rainf$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(rainf = ifelse(abs(rainf_TVa) < 1.64, 0, rainf)
  )
SDF.coef$rainf %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    rainf = ifelse(rainf > 0.02, 0.02, rainf),
    rainf = ifelse(rainf < -0.02, -0.02, rainf)
  )

grob_add <- grobTree(textGrob("a",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "white", fontsize = 14)))
pal <- colorRampPalette(c("blue","green", "white", "yellow","red"))
plot.pair.background <- ggmap(tokyo_basemap) +
    geom_sf(data = SDF.coef, aes(color = rainf), alpha = 0.1, size = 0.5, inherit.aes = FALSE) +
    scale_color_gradientn(colors = pal(21), limits = c(-0.02, 0.02), name = "Precipitation") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5, inherit.aes = FALSE) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed", inherit.aes = FALSE) +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 12),
          axis.text.y = element_text(size = 12),
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          legend.key.size = unit(0.5, "cm")
    ) +
    scale_x_continuous(labels = function(x) paste0(x, "°"), limits = c(138.9, 140)) +
    scale_y_continuous(labels = function(x) paste0(x, "°"), limits = c(35.4, 36.0)) +
  annotation_custom(grob_add)

# NDVI
GWPR.result.NDVI <- readRDS('12_Results0618/02.GWPR.result.NDVI.rds')
SDF.coef <- GWPR.result.NDVI$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(NDVI = ifelse(abs(NDVI_TVa) < 1.64, 0, NDVI)
  )
SDF.coef$NDVI %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    NDVI = ifelse(NDVI > 0.05, 0.05, NDVI),
    NDVI = ifelse(NDVI < -0.05, -0.05, NDVI)
  )

grob_add <- grobTree(textGrob("b",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "white", fontsize = 14)))
pal <- colorRampPalette(c("blue","green", "white", "yellow","red"))
(plot.NDVI.background <- ggmap(tokyo_basemap) +
    geom_sf(data = SDF.coef, aes(color = NDVI), alpha = 0.1, size = 0.5, inherit.aes = FALSE) +
    scale_color_gradientn(colors = pal(21), limits = c(-0.05, 0.05), name = "NDVI") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5, inherit.aes = FALSE) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed", inherit.aes = FALSE) +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 12),
          axis.text.y = element_text(size = 12),
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          legend.key.size = unit(0.5, "cm")
    ) +
    scale_x_continuous(labels = function(x) paste0(x, "°"), limits = c(138.9, 140)) +
    scale_y_continuous(labels = function(x) paste0(x, "°"), limits = c(35.4, 36.0)) +
    annotation_custom(grob_add)
)

# NTL
GWPR.result.NTL <- readRDS('12_Results0618/02.GWPR.result.NTL.rds')
SDF.coef <- GWPR.result.NTL$SDF
SDF.coef <- st_as_sf(SDF.coef)
SDF.coef <- SDF.coef %>% 
  mutate(NTL = ifelse(abs(NTL_TVa) < 1.64, 0, NTL)
  )
SDF.coef$NTL %>% summary()
SDF.coef <- SDF.coef %>% 
  mutate(
    NTL = ifelse(NTL > 0.04, 0.04, NTL),
    NTL = ifelse(NTL < -0.04, -0.04, NTL)
  )
grob_add <- grobTree(textGrob("c",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "white", fontsize = 14)))
pal <- colorRampPalette(c("blue","green", "white", "yellow","red"))
(plot.NTL.background <- ggmap(tokyo_basemap) +
    geom_sf(data = SDF.coef, aes(color = NTL), alpha = 0.1, size = 0.5, inherit.aes = FALSE) +
    scale_color_gradientn(colors = pal(21), limits = c(-0.04, 0.04), name = "NTL") +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5, inherit.aes = FALSE) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed", inherit.aes = FALSE) +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 12),
          axis.text.y = element_text(size = 12),
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          legend.key.size = unit(0.5, "cm")
    ) +
    scale_x_continuous(labels = function(x) paste0(x, "°"), limits = c(138.9, 140)) +
    scale_y_continuous(labels = function(x) paste0(x, "°"), limits = c(35.4, 36.0)) +
    annotation_custom(grob_add)
)

grob_add <- grobTree(textGrob("d",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "white", fontsize = 14)))
(plot.background <- ggmap(tokyo_basemap)+
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5, inherit.aes = FALSE) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 2, linetype = "dashed", inherit.aes = FALSE) +
    xlim(138.8, 140) +
    ylim(35.4, 36.0) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(size = 12),
          axis.text.y = element_text(size = 12),
          legend.title = element_text(size = 12),
          legend.text = element_text(size = 10),
          legend.key.size = unit(0.5, "cm")
    ) +
    scale_x_continuous(labels = function(x) paste0(x, "°"), limits = c(138.9, 140)) +
    scale_y_continuous(labels = function(x) paste0(x, "°"), limits = c(35.4, 36.0)) +
    annotation_custom(grob_add)
)

jpeg(file="11_Figure0618/GWPR.coef.background.jpeg", width = 300, height = 240, units = "mm", quality = 300, res = 300)
grid.arrange(plot.pair.background,
             plot.NDVI.background,
             plot.NTL.background,
             plot.background,
             nrow = 2)
dev.off()
