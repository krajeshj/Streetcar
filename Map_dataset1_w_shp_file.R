# This program analyzes the instruction trace of a Ultimate Random

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

setwd('/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/DataSet1_4_01_2016')
# examine the files 
dir()

# read in thr csv 
stcar_center<- read_csv("StreetCarParcels_EDGE.csv")

glimpse(stcar_center)
View(stcar_center)

# Function to get data from google servers

#define a function that will process googles server responses for us.
getGeoDetails <- function(address){   
  #use the gecode function to query google servers
  geo_reply = geocode(address, output='all', messaging=TRUE, override_limit=TRUE)
  #now extract the bits that we need from the returned list
  answer <- data.frame(lat=NA, long=NA, accuracy=NA, formatted_address=NA, address_type=NA, status=NA)
  answer$status <- geo_reply$status
  
  #if we are over the query limit - want to pause for an hour
  # while(geo_reply$status == "OVER_QUERY_LIMIT"){
  #   print("OVER QUERY LIMIT - Pausing for 1 hour at:") 
  #   time <- Sys.time()
  #   print(as.character(time))
  #   Sys.sleep(60*60)
  #   geo_reply = geocode(address, output='all', messaging=TRUE, override_limit=TRUE)
  #   answer$status <- geo_reply$status
  # }
  
  #return Na's if we didn't get a match:
  if (geo_reply$status != "OK"){
    return(answer)
  }   
  #else, extract what we need from the Google server reply into a dataframe:
  answer$lat <- geo_reply$results[[1]]$geometry$location$lat
  answer$long <- geo_reply$results[[1]]$geometry$location$lng   
  if (length(geo_reply$results[[1]]$types) > 0){
    answer$accuracy <- geo_reply$results[[1]]$types[[1]]
  }
  answer$address_type <- paste(geo_reply$results[[1]]$types, collapse=',')
  answer$formatted_address <- geo_reply$results[[1]]$formatted_address
  
  return(answer)
}







stcar_center <-mutate(stcar_center, addr_to_geocode = (paste(ADDRNO, ADDRST, ADDRSF, "cincinnati, OH")))




# initialized 

#initialise a dataframe to hold the results
geocoded <- data.frame()
# find out where to start in the address list (if the script was interrupted before):
startindex <- 1

# Start the geocoding process - address by address. geocode() function takes care of query speed limit.





for (ii in seq(startindex, nrow(stcar_center))){
  print(paste("Working on index", ii, "of", nrow(stcar_center)))
  #query the google geocoder - this will pause here if we are over the limit.
  result = getGeoDetails(stcar_center$addr_to_geocode[ii]) 
  print(result$status)     
  result$index <- ii
  #append the answer to the results file.
  geocoded <- rbind(geocoded, result)
  #save temporary results as we are going along
  #saveRDS(geocoded, tempfilename)
}


stcar_center<-bind_cols(stcar_center, geocoded)


myMap <- get_map(location="1208 Sycamore st, Cincinnati,OH", source="google", maptype="roadmap", crop=FALSE, zoom = 15)

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


# Subset streetcar data


stcar_center <- stcar_center %>% filter((!(is.na(ADDRNO)))) %>% ((!(is.na(ADDRST)))) %>% ((is.na(ADDRSF)))

# Rasterize a map
myMap <- get_map('1208 Sycamore st.,Cincinnati,OH', zoom = 14, maptype = 'roadmap')
# Over lay
CinciMap <- ggmap(myMap)  

#CinciMap <- CinciMap +  geom_point(aes( x = as.numeric(long), y = as.numeric(lat), alpha = 1.0, col = EXLUCODE, size= as.numeric(ACREDEED *10)), data= stcar_center)


CinciMap <- CinciMap + geom_polygon(aes(x = long, y = lat, group = group ), data = shp_file_ctr, alpha = 0.1, size = .1, fill = 'purple', color = 'white') 
CinciMap <- CinciMap + geom_polygon(aes(x = long, y = lat, group = group ), data = shp_file_core,  alpha = 0.1, size = .1, fill = 'orangered', color = 'white') 
CinciMap <- CinciMap + geom_polygon(aes(x = long, y = lat, group = group ), data = shp_file_edge, alpha = 0.1, size = .1, fill = 'green', color = 'white') 

# Added a layer for density 
CinciMap <- CinciMap + stat_density2d(
                         aes(x = as.numeric(long), y = as.numeric(lat), fill = ..level..,
                           alpha = ..level..),
                          bins = 6, geom = "polygon", data = stcar_center)



CinciMap <- CinciMap +  geom_point(aes( x = as.numeric(long), y = as.numeric(lat), alpha = 1.0, col = EXLUCODE, size= as.numeric(ACREDEED *10)), data= stcar_center)
 
#CinciMap

 # Create a heat map of Land Values 
 #CinciLandVal <-  ggmap(myMap)
 
  
 CinciMap <- CinciMap + geom_tile(data = stcar_center,inherit.aes = FALSE,
                       aes(x = as.numeric(long), y = as.numeric(lat), alpha = MKTLND/24000000),
                       fill = "red") + theme(axis.title.y = element_blank(), axis.title.x = element_blank())
 
 
 CinciMap
  

 


 
# Data Layer
# n <-(ggplot)
# 
# # Data + Aesthetics Mapping 
# n <-ggplot(data,aes(x= data$Department.Title, y = data$Total.Payments, color=data$Job.Class.Title, alpha=0.4, size=data$Overtime.Pay))
# 
# # Data + aes + Geometries 
# n <- n + geom_jitter() 
# 
# # Data + Aesthetic Mapping +  Geom + Facets
# #n <- n + facet_grid(. ~ Department.Title ) 
# 
# #Data + Aesthetics + Geoms + Facets + Statistics
# # ... add a linear regression model here
# 
# #Data + Aesthetics + Geoms + Facets + Statistics + Co-ordinates
# #n <- n + scale_y_discrete(limits=c("00000","120000"), breaks=seq(00000,120000,10000))
# n <- n + xlab("City of Los Angeles Departments")
# n <- n + ylab("Total Pay")
# 
# #Data + Aesthetics + Geoms + Facets + Statistics + Co-ordinates + Theme 
# n <- n + theme(axis.text.x = element_text(angle=305))
# 
# print(n)





