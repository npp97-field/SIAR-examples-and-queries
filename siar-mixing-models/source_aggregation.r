# load the siar library
library(siar)

# remove any pre-existing and open graphics windows
graphics.off()

# ------------------------------------------------------------------------------
# After that bit of house-keeping. Read in the data files.
# ------------------------------------------------------------------------------

# Instead of reading in data, i am going to specify it directly here since we
# are going to use simulated or at least contrived data.


# specify the sources
sources <- data.frame(sources=c("A","B","C","D"),
                        muC=c(-5,-5,5,5),sdC=c(1,1,1,1),
                        muN=c(-5,5,5,-5),sdN=c(1,1,1,1))


# These are alternative sources where C and D are more closely located in 
# isotope-space.
# specify the sources
#sources <- data.frame(sources=c("A","B","C","D"),
#                        muC=c(-5,-5,5,6),sdC=c(1,1,1,1),
#                        muN=c(-5,5,5,4),sdN=c(1,1,1,1))


# speficy the consumer data at the origin
# Just one consumer for this example, so will use siarsolomcmcv4() to fit
# the model.
consumers <- data.frame(C=0,N=0)


# No corrections (TEF) data for this simple example
# corrections <- read.table("correctionsdemo.txt",header=TRUE)




# ------------------------------------------------------------------------------
# Thats the data read in... now we can run the model and analyse the results
# ------------------------------------------------------------------------------

# this line calls the SIAR model for either multiple or single groups
# of consumers depending on the format of the consumers dataset
model1 <- siarsolomcmcv4(consumers, sources)

# same model with a Jeffrey's prior
model1.jeff <- siarsolomcmcv4(consumers, sources,
                              prior = c(0.25, 0.25, 0.25, 0.25) )

# this line plots the raw isotope data for sources and consumers as a bi-plot.
# The trophic enrichment factors have been applied to the sources.
# You will be asked to position a legend on the screen by left clicking.
#dev.new()
siarplotdata(model1,iso=c(1,2))

# This line plots the estimated proportional contribution of each source in the 
# consumer's diet.
# It will ask you which group you wish to plot the data for.
# There are 8 in this example)
# You will then be asked whether you want the histograms plotted all together
# on one graph, or a seperate graph for each source. Suggest you go for group 3.
#dev.new()
#siarhistograms(model1)

# This function plots the histogram data from the previous example as box-style
# plots showing the highest density regions of the estimated posterior
# distributions. This function plots estimates for a single source across
# all groups. In this example it plots the estimated contribution of grass
# (grp = 2) to the diet across all 8 groups of consumers.
#
# NB this function is not available for siarsolomcmcv4() output.
# siarproportionbysourceplot(model1,grp=1)

# This function plots the histogram data as box-style
# plots showing the highest density regions of the estimated posterior
# distributions. This function plots estimates for a single group of consumers 
# across all their sources.
# In this example it plots the estimated contribution of all 5 sources for 
# the consumer group = 1.
#
# Same data as in the histograms generated above, but now displayed as
# density boxplots.
#dev.new()
siardensityplot(model1$output[, 1:4], xticklabels=c('A','B','C','D'),
                main = "All 4 sources")

siardensityplot(model1.jeff$output[, 1:4], xticklabels=c('A','B','C','D'),
                main = "All 4 sources")

# This gets the 95% credible intervals, modes and means of the estimates
# It returns values for all estimated parameters... ie. the proportion of each
# source in the diet for each group of consumers.
# In this example, ZosteraG1 is the proportion of Zostera aglae in the diet of 
# the consumer geese in the Group 1.
# SD1G1 is the residual error associated with Isotope 1 for consumers in Group 1.
# This value tells you how variable the consumers are within a group, after
# fitting the model.
siarhdrs(model1)

# This line creates some potentially very useful diagnostic plots. It will ask
# you which group you wish to run the analysis for. I suggest for this example
# you select group 3 and compare with the histogram and boxplots for this same
# group that we generated above.
#
# This figure shows very clearly that the model can not tease apart the 4
# potential sources. If proportion of A goes up, so B in the diet must come down.
# If A goes up, C has to go up too to compensate. Bascially, the most likely
# scenario is 25% of each of the 4 sources, but in reality, the model cant
# separate the source contributions.
#dev.new()
siarmatrixplot(model1)

siarmatrixplot(model1.jeff)





# ------------------------------------------------------------------------------
# Now we are going to a priori combine sources C and D 
# ------------------------------------------------------------------------------

# These are alternative sources, generated by grouping sources C and D                        
# specify the sources
combined.sources <- data.frame(sources=c("A","B","CD"),
                        muC = c(sources$muC[c(1,2)], sum(sources$muC[c(3,4)])),
                        sdC = c(sources$sdC[c(1,2)], sqrt(sum(sources$sdC[c(3,4)]^2))),
                        muN = c(sources$muN[c(1,2)], sum(sources$muN[c(3,4)])),
                        sdN = c(sources$sdN[c(1,2)], sqrt(sum(sources$sdN[c(3,4)]^2)))
                        )


model2 <- siarsolomcmcv4(consumers, combined.sources)

#dev.new()
siarplotdata(model2,iso=c(1,2))


#dev.new()
#siarhistograms(model2)

#dev.new()
siardensityplot(model2$output[ , 1:3],
                xticklabels=c('A','B','C+D'),
                main = "Sources C and D combined a priori")


siarhdrs(model2)

# and now apparently we are very sure about the contributions of all sources
# to the diet. There is some correlation between A and B since they need to 
# balance each other out in combination to yield a dB value of 0.
# You would now incorrectly assume that  CD represents pretty much a guaranteed
# 43% of the diet, whereas the appropriate analysis we did earlier tells us
# that 
#dev.new()
siarmatrixplot(model2)

# ------------------------------------------------------------------------------
# The more honest thing to do is aggregate C and D posterior estimates 
# ------------------------------------------------------------------------------
# go back to model1 and aggregate C and D.
CD.posteriori.aggregated <-  cbind(model1$output[,c("A","B")],
                                   rowSums(model1$output[,c("C","D")]))

BCD.posteriori.aggregated <-  cbind(model1$output[,c("A")],
                                   rowSums(model1$output[,c("B","C","D")]))


# this figure illustrates how uncertain we are in the estiamtes, and 
# it differs starkly with the relatively much more certain results stemming 
# from the a priori aggregation.
#dev.new()
siardensityplot(CD.posteriori.aggregated,
                xticklabels=c('A','B','C+D'),
                main = "Sources C and D combined a posteriori")

pairs(CD.posteriori.aggregated,
      diag.panel = panelhist,
      lower.panel = panelcor,
      upper.panel = panelcontour)




