
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

# setwd
#setwd("/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/taxinfo")
# examine the files 
dir()

# some nummbers in the file have , that seperate 000s positio : 6,088.56
# A function  to co-erce the data to be numeric
# in field_col_classes, the DELQ_TAXES column then will be num.with.commas
setAs("character", "num.with.commas", 
      function(from) as.numeric(gsub(",", "", from) ) )
# similar tricks can be done for Y/N values
#setAs("character", "logical.Y.N", function(from) c(Y=TRUE,N=FALSE)[from] )).


# The definitions of the col headers are read into a list from field.txt
names <-scan (file= "/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/taxinfo/2014/field_names.txt", multi.line=TRUE, what = character())
field_col_classes <-scan (file= "/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/taxinfo/2014/field_col_classes.txt", multi.line=TRUE, what = character())
field_width <-scan (file= "/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/taxinfo/2014/field_width.txt", multi.line=TRUE, what = character())

#width = c(20,8,25,6,3,2,1,2,3,4,3,25,25,25,25,25,25,25,25,80,80,80,80,2,1,15,1,14,10,15,1,6,8,2,15,1,15,15,1,8,2,10, 1,9,10,15,15,15, 15, 1, 1,25,25 , 15,10,1, 100),

test_2014.fixed <- read.fwf( n = 20,
                            file = "/Users/rajesh/Desktop/Coursera/SpringBoardGithub/StreetCar/Dataset2_5_28_2016/taxinfo/2014/taxinfo2014.txt", 
                            width = as.numeric(field_width),
                            colClasses = field_col_classes,
                            col.names = names,
                            na.strings= TRUE,
                            fill = TRUE)


 str(test_2014.fixed)