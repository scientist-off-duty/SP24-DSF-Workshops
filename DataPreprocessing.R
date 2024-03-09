getwd()
list.files() 
list.files(pattern = "Preproc")

## install.packages("tidyverse")
library(tidyverse)

#Import data. 
# mmALL_073120_csv <- haven::read_dta("Mass_Mobilizaton_Data.dta")

###### Method 2 ###### 
load("../Data/mmALL_073120_csv.RData")
View(mmALL_073120_csv)

###### Method 3 w/dupes ###### 
mmALL_073120_csv <- read_csv("../Data/mmALL_073120_csv.csv")
View(mmALL_073120_csv)

#Subset columns and rows
###### View all column names in df ###### 
colnames(mmALL_073120_csv)

###### Braindump all potentially relevant variables/columns ###### 
PreprocData <- mmALL_073120_csv %>%
  dplyr::select(protest, participants, participants_category, protestnumber, protesterviolence, region, year, country, ccode, id, startday, startmonth, startyear, endday, endmonth, endyear)

###### Filter rows by Region ###### 
preprec_North_America <- PreprocData %>%
  filter(region == "North America")
View(preprec_North_America)

###### Remove the year column ###### 
PreprocData %>% select(-year)

###### Rename the columns w/ dplry and base R ###### 
PreprocData %>%
  rename(countrycode = ccode)

names(PreprocData)[names(PreprocData) == "ccode"] <- "countrycode"


###### All together, magic of the pipe tool ###### 

PreprocData <- mmALL_073120_csv %>%
  dplyr::select(protest, participants, participants_category, protestnumber, protesterviolence, region, year, country, ccode, id, startday, startmonth, startyear, endday, endmonth, endyear) %>%
  select(-year) %>%
  rename(countrycode = ccode)

###### View all column names in new df ###### 
colnames(PreprocData)


str(PreprocData)

## transforms selected vars
PreprocData_transformed <- PreprocData %>%
  mutate(
    participants = as.numeric(participants),
    participants_category = as.factor(participants_category),
    protestnumber = as.integer(protestnumber),
    protesterviolence = as.factor(protesterviolence),
    startmonth = as.integer(startmonth),
    startyear = as.integer(startyear),
    endday = as.integer(endday),
    endmonth = as.integer(endmonth),
    endyear = as.integer(endyear),
    region = as.factor(region),
    country = as.factor(country)
  ) 
## Known warning message for participants NA numeric data

###### reassign levels of factor variable: participants_category ######
levels(PreprocData_transformed$participants_category) <- list(
  ">10000" = ">10000",
  "100-999" = "100-999",
  "1000-1999" = "1000-1999",
  "2000-4999" = "2000-4999",
  "50-99" = "50-99",
  "5000-10000" = "5000-10000",   
  "NA"="NA")



rownames(PreprocData_transformed)

#Identify and remove duplicates
###### Method 1: Remove duplicate rows ###### 
PreprocData2 <- PreprocData_transformed[!duplicated(PreprocData_transformed), ]

###### Method 2: Remove duplicates by single column ###### 
PreprocData2 <- PreprocData_transformed[!duplicated(PreprocData_transformed$id), ]

###### Method 3: Using dplyr - Remove duplicate rows (all columns) 
PreprocData2 <- PreprocData_transformed %>% distinct()


###### Find missing cells
is.na(PreprocData2)

###### Find rows w/ NA
complete.cases(PreprocData2)

###### Count NA 
sum(is.na(PreprocData2))       ## count all missing observations 
colSums(is.na(PreprocData2))   ## count the number of missing values in each column 

######  Listwise NA Removal and confirmation - compare number of observations
Preproc_NArm <- na.exclude(PreprocData2)

######  Other methods of Listwise NA removal
PreprocData2[complete.cases(PreprocData2),]
na.omit(PreprocData2)
sum(is.na(PreprocData2))
PreprocData2 %>% drop_na()

######  Remove missing values of specified single column
PreprocData2 %>% drop_na(participants)    

######  Remove missing values of specified multiple columns
PreprocData2 %>% drop_na(participants, protesterviolence) 

######  confirm no missing observations in new df
sum(is.na(Preproc_NArm))   

######  confirm no missing values in each column of new df
colSums(is.na(Preproc_NArm)) 



###### Impute mean for participants column ######
preproc_participants_mean_impute <- PreprocData2 %>% 
  mutate(participants = ifelse(is.na(participants),
                               mean(participants, na.rm = T),
                               participants))
summary(preproc_participants_mean_impute$participants)

###### Impute median for participants column ######
preproc_participants_median_impute <- PreprocData2 %>% 
  mutate(participants = ifelse(is.na(participants),
                               median(participants, na.rm = T),
                               participants))
summary(preproc_participants_median_impute$participants)

###### Impute mean for all numeric columns ######                            
preproc_mean_impute <- PreprocData2 %>% 
  mutate_if(is.numeric, function(x) ifelse(is.na(x), mean(x, na.rm = T), x))
summary(preproc_mean_impute)  

###### Impute median for all numeric columns ######  
preproc_median_impute <- PreprocData2 %>% 
  mutate_if(is.numeric, function(x) ifelse(is.na(x), median(x, na.rm = T), x))
summary(preproc_median_impute)   

###### Group by region, Impute NAs participants column ######
###### RUN
preproc_median_tidyimpute <- PreprocData2 %>% 
  group_by(region) %>% 
  mutate(participants = ifelse(is.na(participants), 
                               median(participants, na.rm = TRUE), 
                               participants))
colSums(is.na(preproc_median_tidyimpute))    

######  confirm no missing observations in new df
sum(is.na(preproc_median_tidyimpute))   

######  confirm no missing values in each column of new df
colSums(is.na(preproc_median_tidyimpute)) 




######  install.packages("mice")
######  install.packages("ggmice")

library(mice)
library(ggmice)

library(help = "mice") 
?mice() ## Look at Built-in univariate imputation methods for "methods = "" & Vignettes 


######  run simple multiple imputation over whole df
PreprocData_imp <- mice(PreprocData2, m = 1, seed = 31415, method = "cart")

######  list the actual imputations for startyear
PreprocData_imp$imp$startyear

######  fill data matrix
PreprocData_compl <- complete(PreprocData_imp)

View(PreprocData_compl)
colSums(is.na(PreprocData_compl)) 



######  use lubridate to correct date formatting
Preproc_dates <- preproc_median_tidyimpute %>% 
  mutate(start = lubridate::make_datetime(startyear, startday, startmonth)) %>%   ## error w/o including lubridate::
  mutate(end = lubridate::make_datetime(endyear, endday, endmonth))
summary(Preproc_dates)


######  split date/time columns
###### DO NOT RUN
Preproc_dates_sep <- Preproc_dates %>%
  tidyr::separate(start, c("startyear", "startday", "startmonth"))  %>%
  tidyr::separate(end, c("endyear", "endday", "endmonth"))
summary(Preproc_dates)


######  computing new variables w/ multiple existing w/difftime()?
Preproc_dates$protest_length = difftime(Preproc_dates$end, Preproc_dates$start, units = "days")
View(Preproc_dates)



## read in and format raw population df
global_population <- read_csv("../Data/population.csv") %>% 
  rename("country"="Country Name",
         "population"="Value") %>% 
  select(-"Country Code")

## check changes
head(global_population)

## match population by country and startyear
Preproc_join <- Preproc_dates %>% 
  dplyr::semi_join(Preproc_dates, global_population, by = c("country", "startyear"))
View(Preproc_join)



###### Review summary stats of df to select numeric columns with possible outliers 
summary(Preproc_join)

###### Visual approach: Histogram, scatter plot, and boxplot
#par(mfrow=c(1,1))
hist(Preproc_join$participants, main = "Histogram")
boxplot(Preproc_join$participants, main = "Boxplot")
plot(Preproc_join$region, Preproc_join$participants)
plot(Preproc_join$region, Preproc_join$protest_length)
qqnorm(Preproc_join$participants, main = "Normal Q-Q plot")

###### IQR method on participants column ###### 
Preproc_OutIQR <- Preproc_join %>% 
  select(id, region, country, protest, protestnumber, participants, start, end, participants, protesterviolence) %>%
  group_by(participants) %>% 
  mutate(IQR = IQR(Preproc_join$participants),
         O_upper = quantile(participants, probs=c( .75), na.rm = FALSE)+1.5*IQR,  
         O_lower = quantile(participants, probs=c( .25), na.rm = FALSE)-1.5*IQR  
  ) %>% 
  filter(O_lower <= participants & participants <= O_upper)

## Results: Shows No outliers present
dim(Preproc_join)
dim(Preproc_OutIQR)


###### Mean +/- 3 Standard Deviations

ptps = Preproc_join$participants
mean = mean(ptps)
std = sd(ptps)

Tmin = mean-(3*std)  ##find outliers
Tmax = mean+(3*std)

ptps[which(ptps < Tmin | ptps > Tmax)]   ##remove outliers
ptps[which(ptps > Tmin & ptps < Tmax)]

###### Median Absolute Deviation (MAD)

med = median(ptps)
abs_dev = abs(ptps-med)
mad = 1.4826 * median(abs_dev)

Tmin = med-(3*mad) 
Tmax = med+(3*mad) 

ptps[which(ptps < Tmin | ptps > Tmax)]
ptps[which(ptps > Tmin & ptps < Tmax)]

###### Inspect DF to determine if data we want is long or wide
View(Preproc_OutIQR)

###### Making long region data wide w/ pivot_wider()
ncol(Preproc_OutIQR)
Preproc_wide <- 
  Preproc_OutIQR  %>% 
  tidyr::pivot_wider(names_from = "region", 
                     values_from = "participants")
ncol(Preproc_wide)


###### Sort observations in descending order by protest startyear
Preproc_wide$start %>% 
  sort(decreasing = TRUE)

###### Reordering columns ######
head(Preproc_wide)

Preproc_wide <- Preproc_wide %>%
  select(id, country, protest, protestnumber, start, end, protesterviolence)


Preproc_long <- Preproc_NArm %>% 
  arrange(region, country) 
View(Preproc_long)

Preproc_long %>%
  group_by(region) %>%
  summarise(median = median(participants), n = n())

###### calculate summary statistics values by month for each variable
Preproc_long %>% 
  group_by(region) %>% 
  summarize(violence = sum(as.numeric(protesterviolence), na.rm = T))



## Sources

#-   Gillespie, C. & Lovelace, R. (2016). Efficient R programming
#<https://bookdown.org/csgillespie/efficientR/>
#  -   Wickham, H. (2014). Tidy Data. Journal of Statistical Software,
#59(10), 1--23. <https://doi.org/10.18637/jss.v059.i10>
#  -   Wickham, H., Çetinkaya-Rundel, M., Grolemund, G. (2023) R for Data
#Science, 2e. <https://r4ds.hadley.nz/>
#  -   <https://bookdown.org/yihui/bookdown/>
#  -   **YAML Syntax -**
#  -   <https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html>
#  -   <https://rstudio.github.io/cheatsheets/html/lubridate.html?_gl=1*iabz4g*_ga*MTAwNzU0ODg4NC4xNzA1NTExNDA4*_ga_2C0WZ1JHG0*MTcwNTUxMzk2Ni4yLjEuMTcwNTUxNTExNC4wLjAuMA>
#  -   <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4731595/>
#  -   <https://www.jstatsoft.org/article/view/v045i03>
#  -   <https://rpubs.com/brouwern/meanimpute>
#  -   **Data Wrangling with R, [UNIVERSITY of WISCONSIN--MADISONSocial
#                                Science Computing Cooperative](http://www.wisc.edu/):**
#  <https://sscc.wisc.edu/sscc/pubs/dwr/index.html>
#  -   

