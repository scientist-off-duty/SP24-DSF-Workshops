# Feature Extraction Workshop

## Data Prep ----

## Set Seed
set.seed(31415)

## Load Libraries
# install.packages()
library(tidyverse)
library(corrplot)
library(stats)
library(psych)
library(ggpubr) # needed for MDS
library(MASS) # needed for LDA 

## Load & Examine Dataset
# Download from github: https://github.com/ccss-rs
getwd()
list.files()
data <- read_csv("/Users/aishatsadiq/Library/Mobile Documents/iCloud~md~obsidian/Documents/PhD/CCSS Data Fellow/labor_market_discrimination.csv")

summary(data)
# attributes(data)

# Filter numeric vars
colnames(data)
numeric_vars <- dplyr::select(data, "call", "n_jobs","years_exp", "frac_black","frac_white", 
                              "l_med_hh_inc","frac_dropout","frac_colp","l_inc","parent_sales",
                              "parent_emp","branch_sales","branch_emp","frac_black_emp_zip",   
                              "frac_white_emp_zip","l_med_hh_inc_emp_zip","frac_dropout_emp_zip","frac_colp_emp_zip","l_inc_emp_zip") %>% drop_na()

numeric_vars = as.data.frame(numeric_vars)

# Step 1: Standardize data
numeric_vars_standard <- data.frame(scale(numeric_vars, center=TRUE, scale=TRUE))

# sanity check
View(numeric_vars_standard)
View(numeric_vars)

# Step 2: Compute correlation matrix
cormatrix <- stats::cor(numeric_vars_standard)
View(cormatrix)
# 'AOE' for the angular order of the eigenvectors.
corrplot(cormatrix, method = "shade", type="full", order = "AOE", insig = "blank")

# 'FPC' for the first principal component order.
corrplot(cormatrix, method = "shade", type="full", order = "FPC", insig = "blank")

## Step 3: Determine number of factors (using Cattell's scree test in psych package)
scree(numeric_vars_standard, factors=TRUE, pc=TRUE)  # Use pc=FALSE for factor analysis

# another way of showing the scree & compare it to randomly parallel solutions
# “Parallel" analyis is an alternative technique that compares the scree of factors of the observed data with that of a random data matrix of the same size as the original. 
fa.parallel(numeric_vars_standard, fa="both") 

## Step 4: Extract (and rotate) factors
# assumption of uncorrelated (independent) factors
# options: promax, oblimin
# assumption of correlated (non-independent) factors
# options: varimax(), quartimax, equamax

### Maximum Likelihood Factor Analysis with no rotation
### "regression" gives Thompson's scores, "Bartlett" given Bartlett's weighted least-squares scores
fit_no_rotate <- factanal(~ .,data=numeric_vars_standard, factors = 7, rotation="none",scores = "regression")

# Check for convergence
names(fit_no_rotate)
fit_no_rotate$converged

print(fit_no_rotate, digits=2, cutoff=0.3, sort=TRUE)

###  Maximum Likelihood Factor Analysis with varimax rotation (test with cerying factor numbers)             
# orthogonally rotates the factor axes with the goal of maximizing the variance of the squared loadings of a factor on all the variables
fit_varimax_rotate <- factanal(~ .,data=numeric_vars_standard, factors = 7, rotation="varimax",na.action = na.exclude)

# Check for convergence
fit_varimax_rotate$converged

print(fit_varimax_rotate, digits=2, cutoff=0.3, sort=TRUE)

###  Maximum Likelihood Factor Analysis with promax rotation                
# oblique transformation, assumes factors are correlated
fit_promax_rotate <- factanal(~ .,data=numeric_vars_standard, factors = 7, rotation="promax",na.action = na.exclude)

# Check for convergence
fit_promax_rotate$converged

print(fit_promax_rotate, digits=2, cutoff=0.3, sort=TRUE)

## Step 4: Visualize  
loads <- fit_promax_rotate$loadings
fa.diagram(loads)

# Classical MDS using stats package ----

euclidean_distances <- dist(numeric_vars_standard) # euclidean distances between the rows
ClassicalMDS_fit <- cmdscale(euclidean_distances,eig=TRUE, k=2) # k is the number of dim
ClassicalMDS_fit # view results

# plot solution
x <- ClassicalMDS_fit$points[,1]
y <- ClassicalMDS_fit$points[,2]
plot(x, y, xlab="Coordinate 1", ylab="Coordinate 2",
  main="Metric MDS", type="n")
text(x, y, labels = row.names(numeric_vars_standard), cex=.7)



#Linear Discriminant Analysis w/ MASS package
linear <- lda(call~., numeric_vars_standard)
linear
