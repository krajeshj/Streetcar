library(dplyr)
library(RSQLite)
library(tidyr)
library(ggplot2)
library(readr)
library(stringr)
library(scales)
library(mixtools)
library(readxl)
library(ggmap)
library(maptools)

library(rgdal)

# read data into R
#shapefile <- readShapeSpatial('/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/streetcarbuffer_parcels/gis_shape_files/gis_shapeFiles_studyarea_Parcels/CENTER_PARCELS.shp',
#                              proj4string = CRS("+proj=longlat +datum=WGS84"))
# Paste the contents of .prj file in http://prj2epsg.org/search : youll get a number 
# Then go to SpatialResearch and  paste the code in the search box to get yhr proj4string
#shapefile <- readShapeSpatial('/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/streetcarbuffer_parcels/gis_shape_files/gis_shapeFiles_studyarea_Parcels/CENTER_PARCELS.shp',
#                              proj4string = CRS("+proj=lcc +lat_1=40.03333333333333 +lat_2=38.73333333333333 +lat_0=38 +lon_0=-82.5 +x_0=600000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs "))


###############
#CENTER PARCELS : Convert shape files to data
###############
shp_file_ctr <- readOGR('/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/streetcarbuffer_parcels/gis_shape_files/gis_shapeFiles_studyarea_Parcels/CENTER_PARCELS.shp',
                         layer="CENTER_PARCELS"     )
proj4string(shp_file_ctr)
shp_file_ctr <- spTransform(shp_file_ctr, CRS("+proj=longlat +datum=WGS84"))

# convert to a data.frame for use with ggplot2/ggmap and plot
data <- fortify(shp_file_ctr)

###############
#CORE PARCELS : Convert shape files to data
###############
shp_file_core <- readOGR('/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/streetcarbuffer_parcels/gis_shape_files/gis_shapeFiles_studyarea_Parcels/CORE_PARCELS.shp',
                        layer="CORE_PARCELS"     )
proj4string(shp_file_core)
shp_file_core <- spTransform(shp_file_core, CRS("+proj=longlat +datum=WGS84"))

# convert to a data.frame for use with ggplot2/ggmap and plot
data <- fortify(shp_file_core)

###############
#CORE PARCELS : Convert shape files to data
###############
shp_file_edge <- readOGR('/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/streetcarbuffer_parcels/gis_shape_files/gis_shapeFiles_studyarea_Parcels/EDGE_PARCELS.shp',
                         layer="EDGE_PARCELS"     )
proj4string(shp_file_edge)
shp_file_edge <- spTransform(shp_file_edge, CRS("+proj=longlat +datum=WGS84"))

# convert to a data.frame for use with ggplot2/ggmap and plot
data <- fortify(shp_file_edge)






# Rasterize a map
myMap <- get_map('1208 Sycamore st.,Cincinnati,OH', zoom = 14, maptype = 'roadmap')
# Over lay
ggmap(myMap)+ geom_polygon(aes(x = long, y = lat, group = group ), data = shp_file_ctr,
              alpha = 0.5, size = .3, fill = 'purple', color = 'white') + geom_polygon(aes(x = long, y = lat, group = group ), data = shp_file_core,
               alpha = 0.5, size = .3, fill = 'orangered', color = 'white') + geom_polygon(aes(x = long, y = lat, group = group ), data = shp_file_edge,
               alpha = 0.5, size = .3, fill = 'green', color = 'white') 
  