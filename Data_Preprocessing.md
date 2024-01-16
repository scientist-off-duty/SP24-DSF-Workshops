Data Cleaning                                              
========================================================
author: Aishat Sadiq
date: February 7th, 2024
autosize: true

AS TODO 
========================================================

**add code to each section**

* All slides - increase title & body font size
* Houston - add transition to show answer after question, add descriptive image
* "Traditionally..." slide - add images/examples of messy vs tidy data to break up white space
* Applications - create or find image of: data cleaning -> ML -> DATA VIZ
* Load Libraries - edit explanation of dependant pkgs, confirm if necessary to include haven since its in tidyverse, 
* Define research question & vars of interest based on df
* Code only -> 


Houston, we have a problem!
========================================================

**need the above space bc it will read as a formatting input**

How much data is created each day?

[It’s estimated that 1.7 MB of data are created every second for every person on earth—the same amount of data needed to store an 850 page book, per second.](https://time.com/6108001/data-protection-richard-stengel/)

Folder structure - keep it short
========================================================

subdirectories: raw data, processed data, code*, documentation
mention: getwd*, relative paths and reproducibility
working directory should be code folder

*Note - walkthrough in Finder on desktop

https://bookdown.org/csgillespie/efficientR/
"Tip: Keep your R installation and packages up-to-date"


Git Version Control
========================================================

Tools > Version Control > Git > Select staged > Commit > Push
* do not commit raw data bc it can become computationally expensive to keep track of, add line of code to gitignore (raw_data/)

Traditionally, what did Hadley Wickham mean by 'Tidy Data'?
========================================================

- Column headers are values, not variable names.
- Multiple variables are stored in one column.
- Variables are stored in both rows and columns.
- Multiple types of observational units are stored in the same table.
- A single observational unit is stored in multiple tables.

Applications
========================================================
title: false
left: 80%

**Tidy data...**

1. Makes it easier to focus on manipulating and analyzing data

2. Makes data visualization simpler and more intuitive

3. Help ML algorithms perform and learn more effectively

image: data cleaning -> ML -> DATA VIZ

"Modeling is the driving inspiration of this work because most modeling tools work best with tidy datasets." Hadley Wickham

Load Libraries
========================================================

Tidyverse package was created by Hadley Wickham. 
Learn more about the 'tidyverse' at <https://www.tidyverse.org> 
or <https://github.com/tidyverse/tidyverse>

- show imports section of library help page - these are the dependent packages installed to allow the new one to function
-- Hightlight dplyr (>= 1.0.5)
- show 'Depends' R version required for the package to function correctly


```r
library(help = "tidyverse") 
```



```r
options(stringsAsFactors = FALSE)

library(tidyverse)
library(lubridate)
#library(dplyr)
library(haven)    # needed to open .dta file in R
```

Import messy data
========================================================

[Harvard Dataverse>Mass Mobilization Data Project Dataverse](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/HTTWYL)
























```
processing file: Data_Preprocessing.Rpres
── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
✔ ggplot2 3.4.4     ✔ purrr   0.3.4
✔ tibble  3.2.1     ✔ dplyr   1.1.3
✔ tidyr   1.2.0     ✔ stringr 1.4.0
✔ readr   2.1.2     ✔ forcats 0.5.1
── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()

Attaching package: 'lubridate'

The following objects are masked from 'package:base':

    date, intersect, setdiff, union

Quitting from lines 107-117 (Data_Preprocessing.Rpres) 
Error: 'Mass_Mobilizaton_Data.dta' does not exist in current working directory ('/Users/aishatsadiq/Library/Mobile Documents/iCloud~md~obsidian/Documents/PhD/CCSS Data Fellow/SP24').
In addition: Warning message:
In do_once((if (is_R_CMD_check()) stop else warning)("The function xfun::isFALSE() will be deprecated in the future. Please ",  :
  The function xfun::isFALSE() will be deprecated in the future. Please consider using base::isFALSE(x) or identical(x, FALSE) instead.
Execution halted
```
