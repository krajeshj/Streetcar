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

# examine the files 
dir()

# read in thr csv 
stcar_center<- read_csv("StreetCarParcels_CENTER.csv")

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

stcar_center <-mutate(stcar_center, prop_val = (MKTLND + MKTIMP))


myMap <- get_map(location="1208 Sycamore st, Cincinnati,OH", source="google", maptype="roadmap", crop=FALSE, zoom = 15)

long <- c(-84.500, -84.505,-84.515, 84.500, -84.505,-84.515,84.500, -84.505,-84.515, -84.515,84.500, -84.505 )
lat <- c(39.120,39.115,39.110, 39.120,39.115,39.110,  39.120,39.115,39.110 ,  39.120,39.115,39.110 )
pval <- c( 10000,20000,30000, 12345, 24567, 26789, 25647,14567,20222, 30000, 12345, 24567) 
 


test_df  <- data.frame(long,lat,pval)

lg <- as.vector(stcar_center$long)
lt <- as.vector(stcar_center$lat)
pval <- as.vector(stcar_center$MKTLND)

test2_df  <- data.frame(lg,lt,pval)
 
# Create a heat map of Land Values 
CinciLandVal <-  ggmap(myMap)

 
CinciLandVal + geom_tile(data = test_df,
                      aes(x = lg, y = lt, alpha = as.numeric( MKTLND/30000)),
                      fill = "red") + theme(axis.title.y = element_blank(), axis.title.x = element_blank())




 


 
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





