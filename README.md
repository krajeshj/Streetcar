# Streetcar
#Introduction 
A new Streetcar route is about to be commissioned in the City of Cincinnati in fall of 2016. Within a 1000 ft. buffer zone of the route, has there been a net "positive effect " on the economic development? Have the Market Value of the land and its buildings in the buffer zone declined, appreciated or remained the same.  Has there been a trend in restaurant licensing starts? Have building permits been applied and is there a growing trend indicating office growth?

 

#Street Car 

The Cincinnati Streetcar is a modern streetcar system designed to link major employment centers in downtown and uptown, connecting through Cincinnati's historic Over-the-Rhine neighborhood.
It will operate 18 hours a day, 365 days a year.
##1.	What is the problem you want to solve?
Predict a “net positive effect” on economy in the buffer zone around the streetcar route.
##2.	Who is your client and why do they care about this problem?
	The City of Cincinnati would be the client. 
Downtown is Cincinnati’s largest employment center, with approximately 70,000 people in the area every day. It has been proven in cities from Atlanta to Seattle that fixed rails in the ground with thousands of potential riders draw new storefronts and businesses, as well as fixed up housing. That new development will put people to work and boost the city’s tax revenue.
Also, here may have been inconveniences to the neighborhood, during the construction phase.  

Hence, there are two camps of opinion - 
•	one opinion  insists that the introduction of the streetcar is disruptive to the neighborhood ( crowding, transient population, noise) and 
•	The other opinion is that it provides easy access to  business, shops, dining and commuting to work and home and draws new business, expansion of storefronts, revenue from ridership, permit fees, property tax and restaurant license fee.

##3.	What data are you going to use for this? How will you acquire this data? 
•	Data source would be from Open Data Cincinnati and CAGIS, City of Cincinnati, OH. 
•	Identify a buffer zone around the street car route  using parcel ids
o	CSV files for Center, Core and Edge zones
•	Obtain the data for Market value of the Land and Improvements ( tax info) for these  parcels for the last 10 years (CSV)
##4.	In brief, outline your approach to solving this problem (knowing that this might change later).
•	Clean the data
•	Define and build model
•	Establish criteria that defines the economic growth
o	Use historical property values for the last 10 years
o	Predict property value trends using Time series 
•	Visualize using ggmap / ggplot
##5.	What are your deliverables? 
•	Marked up Code in the github
•	Slide-deck with Analysis and Visualization

##References
1.	https://dev.socrata.com/foundry/data.cincinnati-oh.gov/emnx-rw6d
2.	http://www.cincinnati.com/story/news/2016/05/05/streetcar-nation-kc-opens-friday-cincy-next/83874740/
