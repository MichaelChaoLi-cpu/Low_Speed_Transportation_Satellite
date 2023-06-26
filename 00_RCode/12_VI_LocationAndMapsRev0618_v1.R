# Author: M.L.

# Visualization

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
