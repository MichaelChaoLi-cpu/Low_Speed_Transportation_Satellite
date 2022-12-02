# Author: M.L.

# end

library(dplyr)
library(tidyverse)
library(tmap)
library(rgdal)
library(ggplot2)
library(sf)
library(ggspatial) # scale bars and north arrows
library(ggmap)
library(cowplot)
library(ggrepel)
library(plotrix)

register_google(key = "XXXX")

setwd("./04_Data/shp/")
shape_Japan_pref <- readOGR(dsn = ".", layer = "jpn_admbnda_adm1_2019")
shape_Japan_pref@data$tokyo <- 0
shape_Japan_pref@data <- shape_Japan_pref@data %>%
  mutate(tokyo = ifelse(ADM1_PCODE=="JP13", 1, 0))
shape_Japan_pref@data$tokyo <- shape_Japan_pref@data$tokyo %>% as.factor()
shape_Japan_pref <- st_as_sf(shape_Japan_pref)
shape_Japan_pref <- st_transform(shape_Japan_pref, crs = 4326)

df <- data.frame(x = c(139.839478, 139.4019539), y = c(35.652832, 34.7387645), name = c("Tokyo", "Oshima Machi"))
plot.1 <- ggplot() +
  geom_sf(data = shape_Japan_pref, color = "grey65", aes(fill = tokyo), alpha = 1, size = 0.01,
          show.legend = FALSE) +
  scale_fill_manual(values = c("gray100", "red")) +
  geom_point(data = df, aes(x = x, y = y), color = "red") +
  geom_label_repel(data = df, aes(x = x, y = y,label = name),
                   box.padding   = 0.35, 
                   point.padding = 0.5,
                   segment.color = 'grey50', alpha = 0.4) +
  annotation_scale(location = "br", width_hint = 0.4) +
  annotation_north_arrow(location = "br", which_north = "true", 
                         pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
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
  xlim(138.8, 140) +
  ylim(35.3, 36.1) + 
  annotation_scale(location = "bl", width_hint = 0.4) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +
  theme_bw() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank()
  )
plot.2

tokyo_island_basemap <- get_map( c(left = 139.34, bottom = 34.65, right = 139.45, top = 34.8),
                                 zoom = 10, maptype = 'terrain-background', source = 'stamen')
ggmap(tokyo_island_basemap)

plot.3 <- ggmap(tokyo_island_basemap) +
  geom_sf(data = shape_Japan_city, color = "grey65", aes(fill = tokyo), alpha = 0.4, size = 0.5,
          show.legend = FALSE, inherit.aes = FALSE) +
  scale_fill_manual(values = c("gray88", "red")) +
  xlim(139.34, 139.45) +
  ylim(34.65, 34.8) + 
  annotation_scale(location = "bl", width_hint = 0.4) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1, size=7),
        axis.text.y = element_text(size=7),
        axis.title.x = element_blank(),
        axis.title.y = element_blank()
        )
plot.3

locationWithMulti <- ggdraw() +
  draw_plot(plot.3, x = 0, y = 0, width = .25, height = .6) +
  draw_plot(plot.1, x = 0, y = .6, width = .25, height = .4) +
  draw_plot(plot.2, x = .25, y = 0, width = 0.75, height = 1) +
  draw_plot_label(label = c("A", "B", "C"), size = 15,
                  x = c(0, 0.25, 0), y = c(1, 1, 0.63))
setwd("../../")

jpeg(file="06_Figure/locationWithMulti.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
locationWithMulti
dev.off()

### coefficient
pal <- colorRampPalette(c("blue","green","yellow","red"))
pal(20)
tokyo_boudary <- shape_Japan_pref %>% filter(ADM1_PCODE == "JP13")

load("03_Results/GWPR_FEM_CV_F_result_lowSpeedDensity_0015.Rdata")
SDF.coef <- GWPR.FEM.CV.F.result$SDF
SDF.coef <- st_as_sf(SDF.coef)

### NTL
SDF.coef$NTL <- SDF.coef$NTL %>% as.numeric() 
summary(SDF.coef$NTL)
mean(SDF.coef$NTL)
mean(SDF.coef$NTL) - 1.96 * std.error(SDF.coef$NTL)
mean(SDF.coef$NTL) + 1.96 * std.error(SDF.coef$NTL)
SDF.coef <- SDF.coef %>% 
  mutate(NTL = ifelse(NTL>3000, 3000, NTL))
(plot.NTL.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = NTL), alpha = 0.8, size = 0.5) +
    scico::scale_color_scico(palette = "vik", limits = c(-3000, 3000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.3, 36.1) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
  )
  
(plot.NTL.02 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = NTL), alpha = 0.8, size = 2, show.legend = F) +
    scico::scale_color_scico(palette = "vik", limits = c(-3000, 3000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(139.34, 139.45) +
    ylim(34.65, 34.8) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

plot.NTL <- ggdraw() +
  draw_plot(plot.NTL.01, x = 0, y = 0, width = 0.65, height = 1) +
  draw_plot(plot.NTL.02, x = 0.65, y = 0, width = 0.3, height = 1) +
  draw_plot_label(label = c("A", "B"), size = 15,
                  x = c(0, 0.65), y = c(0.8, 0.8))
jpeg(file="06_Figure/NTL.Coeff.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
plot.NTL
dev.off()

### NDVI
SDF.coef$NDVI <- SDF.coef$NDVI %>% as.numeric() 
SDF.coef$NDVI %>% hist()
SDF.coef <- SDF.coef %>% 
  mutate(NDVI = ifelse(NDVI < -30000, -30000, NDVI),
         NDVI = ifelse(NDVI > 30000, 30000, NDVI)
         )
(plot.NDVI.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = NDVI), alpha = 0.8, size = 0.5) +
    scico::scale_color_scico(palette = "vik", limits = c(-30000, 30000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.3, 36.1) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

(plot.NDVI.02 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = NDVI), alpha = 0.8, size = 2, show.legend = F) +
    scico::scale_color_scico(palette = "vik", limits = c(-30000, 30000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(139.34, 139.45) +
    ylim(34.65, 34.8) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

plot.NDVI <- ggdraw() +
  draw_plot(plot.NDVI.01, x = 0, y = 0, width = 0.65, height = 1) +
  draw_plot(plot.NDVI.02, x = 0.65, y = 0, width = 0.3, height = 1) +
  draw_plot_label(label = c("A", "B"), size = 15,
                  x = c(0, 0.65), y = c(0.8, 0.8))
jpeg(file="06_Figure/NDVI.Coeff.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
plot.NDVI
dev.off()

### Temperature
SDF.coef$Temperature <- SDF.coef$Temperature %>% as.numeric() 
SDF.coef$Temperature %>% hist()
SDF.coef <- SDF.coef %>% 
  mutate(Temperature = ifelse(Temperature < -10000, -10000, Temperature),
         Temperature = ifelse(Temperature > 10000, 10000, Temperature)
  )
(plot.Temperature.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = Temperature), alpha = 0.8, size = 0.5) +
    scico::scale_color_scico(palette = "vik", limits = c(-10000, 10000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.3, 36.1) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

(plot.Temperature.02 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = Temperature), alpha = 0.8, size = 2, show.legend = F) +
    scico::scale_color_scico(palette = "vik", limits = c(-10000, 10000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(139.34, 139.45) +
    ylim(34.65, 34.8) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

plot.Temperature <- ggdraw() +
  draw_plot(plot.Temperature.01, x = 0, y = 0, width = 0.65, height = 1) +
  draw_plot(plot.Temperature.02, x = 0.65, y = 0, width = 0.3, height = 1) +
  draw_plot_label(label = c("A", "B"), size = 15,
                  x = c(0, 0.65), y = c(0.8, 0.8))
jpeg(file="06_Figure/Temperature.Coeff.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
plot.Temperature
dev.off()

### prevalance
SDF.coef$prevalance <- SDF.coef$prevalance %>% as.numeric() 
SDF.coef$prevalance %>% hist()
SDF.coef <- SDF.coef %>% 
  mutate(prevalance = ifelse(prevalance < -1000000, -1000000, prevalance),
         prevalance = ifelse(prevalance > 1000000, 1000000, prevalance)
  )
(plot.prevalance.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = prevalance), alpha = 0.8, size = 0.5) +
    scico::scale_color_scico("Prevalance", palette = "vik", limits = c(-1000000, 1000000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.3, 36.1) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

(plot.prevalance.02 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = prevalance), alpha = 0.8, size = 2, show.legend = F) +
    scico::scale_color_scico(palette = "vik", limits = c(-1000000, 1000000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(139.34, 139.45) +
    ylim(34.65, 34.8) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

plot.prevalance <- ggdraw() +
  draw_plot(plot.prevalance.01, x = 0, y = 0, width = 0.65, height = 1) +
  draw_plot(plot.prevalance.02, x = 0.65, y = 0, width = 0.3, height = 1) +
  draw_plot_label(label = c("A", "B"), size = 15,
                  x = c(0, 0.65), y = c(0.8, 0.8))
jpeg(file="06_Figure/prevalance.Coeff.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
plot.prevalance
dev.off()

### emergence
SDF.coef$emergence <- SDF.coef$emergence %>% as.numeric() 
SDF.coef$emergence %>% hist()
SDF.coef <- SDF.coef %>% 
  mutate(emergence = ifelse(emergence < -300000, -300000, emergence),
         emergence = ifelse(emergence > 300000, 300000, emergence)
  )
(plot.emergence.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = emergence), alpha = 0.8, size = 0.5) +
    scico::scale_color_scico("Lockdown Ratio", palette = "vik", limits = c(-300000, 300000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(138.8, 140) +
    ylim(35.3, 36.1) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

(plot.emergence.02 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = emergence), alpha = 0.8, size = 2, show.legend = F) +
    scico::scale_color_scico(palette = "vik", limits = c(-300000, 300000)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "red", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(139.34, 139.45) +
    ylim(34.65, 34.8) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

plot.emergence <- ggdraw() +
  draw_plot(plot.emergence.01, x = 0, y = 0, width = 0.65, height = 1) +
  draw_plot(plot.emergence.02, x = 0.65, y = 0, width = 0.3, height = 1) +
  draw_plot_label(label = c("A", "B"), size = 15,
                  x = c(0, 0.65), y = c(0.8, 0.8))
jpeg(file="06_Figure/emergence.Coeff.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
plot.emergence
dev.off()

### plot mean value
df.ori <- GWPR.FEM.CV.F.result$raw.data %>% 
  dplyr::select("id", "lowSpeedDensity")
df.ori <- stats::aggregate(df.ori[,c("lowSpeedDensity")],
                           by = list(df.ori$id), mean)
colnames(df.ori)[1] <- "id" 
SDF.coef <- left_join(SDF.coef, df.ori, by = "id")
SDF.coef$x %>% hist()
SDF.coef <- SDF.coef %>% 
  mutate(x = ifelse(x > 1000000, 1000000, x))

(plot.x.01 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = x), alpha = 0.8, size = 0.5) +
    scale_color_gradientn("Mean", colors = pal(20)) +
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
    )
)

(plot.x.02 <- ggplot() +
    geom_sf(data = SDF.coef, aes(color = x), alpha = 0.8, size = 2, show.legend = F) +
    scale_color_gradientn("Mean", colors = pal(20)) +
    geom_sf(data = shape_Japan_city, color = "grey10", fill = NA, alpha = 0.4, size = 0.5) +
    geom_sf(data = tokyo_boudary, color = "black", fill = NA, alpha = 0.8, size = 1, linetype = "dashed") +
    xlim(139.34, 139.45) +
    ylim(34.65, 34.8) + 
    annotation_scale(location = "bl", width_hint = 0.4) +
    annotation_north_arrow(location = "bl", which_north = "true", 
                           pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                           style = north_arrow_fancy_orienteering) +
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.title.x = element_blank(),
          axis.title.y = element_blank()
    )
)

plot.x <- ggdraw() +
  draw_plot(plot.x.01, x = 0, y = 0, width = 0.65, height = 1) +
  draw_plot(plot.x.02, x = 0.65, y = 0, width = 0.3, height = 1) +
  draw_plot_label(label = c("A", "B"), size = 15,
                  x = c(0, 0.65), y = c(0.8, 0.8))
jpeg(file="06_Figure/meanX.Coeff.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
plot.x
dev.off()