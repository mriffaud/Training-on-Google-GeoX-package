# intall the package directly from GitHub - it requires  'devtools'
library(devtools)
install_github("google/GeoexperimentsResearch")
#install_github("Google/CausalImpact") # package that create synthetic control set

library(GeoexperimentsResearch)

#Load the data
data(salesandcost)# dataset available in the package
head(salesandcost)

#Create an object 
obj.gta <- GeoTimeseries(salesandcost, metrics = c('sales', 'cost'))
head(obj.gta)
str(obj.gta)

#Aggreagte the data by week and plot it
aggregate(obj.gta, by = '.weekindex')
plot(obj.gta)

#Defining what your experiment periods
obj.per <- ExperimentPeriods(c("2015-01-05", "2015-02-16", "2015-03-15")) 
# for cool down period you just need to add a date at the end your end of cool down period
obj.per

#Defining geo assignment
#for the purpose of this training we assume we already have an assignment (control or test group) we did on the side and load the data from the package
data("geoassignment")
head(geoassignment)

#Create a new object
obj.ga <- GeoAssignment(geoassignment)
head(obj.ga)

#Putting it all together
obj <- GeoExperimentData(obj.gta,
                         periods = obj.per,
                         geo.assignment = obj.ga)
head(obj)

# Aggreragete this object to see the revenue and cost metric
aggregate(obj, by = c('period', 'geo.group'))

#### Time based regression ####
#Using by default 90% confidence interval
obj.tbr <- DoTBRAnalysis(obj,
                         response = 'sales',
                         model = 'tbr1',
                         pretest.period = 0,
                         intervention.period = 1,
                         cooldown.period = NULL, # we did not have a cooldown period
                         control.group = 1,
                         treatment.group = 2)
head(obj.tbr)
summary(obj.tbr)
plot(obj.tbr)
#Look at the outliars analysis package 'leave one out' if 3 SD remove the data points

#Time based reg. ROAS Analysis
obj.tbr.roas <- DoTBRROASAnalysis(obj,
                                  response = 'sales',
                                  cost = 'cost',
                                  model = 'tbr1',
                                  pretest.period = 0,
                                  intervention.period = 1,
                                  cooldown.period = NULL, # we did not have a cooldown period
                                  control.group = 1,
                                  treatment.group = 2)
obj.tbr.roas
#'estimate' minus 'precision' is your 'lower'
#we still have by default 90% conf interval

#Specify a dif confidence level (here 95%)
summary(obj.tbr.roas, level = 0.95, interval.type = 'two-sided')

#Can also specify the treshold = probability of it being above 3
summary(obj.tbr.roas, threshold = 3.0)

plot(obj.tbr.roas)

#It is good to be conservative, yet realistic: keeping a ROAS between 3 to 4 is reasonnable
