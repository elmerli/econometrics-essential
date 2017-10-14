# makefile.R
# Maxwell Austensen
# AEM Replication
# 19-12-2016


# Set directories ---------------------------------------------------------

# This will all work on Mac or Windows

# Note: these paths need to use forward slashes "/"

# Set location of all code files
root_ <- "/Users/Maxwell/repos/aem/replication/"

# Set location of raw data file ("usa_00005.dta)
raw_ <- "/Users/Maxwell/Box Sync/aem/replication/data/raw/"

# Set location for cleaned data files and tables output
clean_ <- "/Users/Maxwell/Box Sync/aem/replication/data/clean/"


# Do not edit below -------------------------------------------------------


# Install packages if needed
package_list <- c("tidyverse", "feather", "knitr", "sandwich", "rmarkdown")
new_packages <- package_list[!package_list %in% installed.packages()[,"Package"]]
if(length(new_packages)) install.packages(new_packages)

# Load required packages
library(tidyverse)
library(haven)
library(stringr)
library(feather)
library(knitr)
library(broom)
library(sandwich)

# Clean out any previous work
outputs <- c("sample1.feather", "sample2.feather", "sample3.feather", # 1_samples.R
             "table1.feather",                                        # 2_descriptives.R
             "table2.feather",                                        # 3_first_stage.R
             "table3.feather",                                        # 4_mean_diffs.R
             "table4.feather",                                        # 5_divorce_effect_overall.R
             "table5.feather")                                        # 6_divorce_effect_by_age.R

file.remove(str_c(clean_, outputs), full.names = TRUE, showWarnings = FALSE)


# Set working directory
setwd(root_)

# Run scripts to create tables
source("1_samples.R")
source("2_descriptives.R")
source("3_first_stage.R")
source("4_mean_diffs.R")
source("5_divorce_effect_overall.R")
source("6_divorce_effect_by_age.R")

# Render final tables output document
rmarkdown::render(input = str_c(root_, "7_all_tables.Rmd"),
                  output_format = "html_document",
                  output_file = "all_tables.html",
                  output_dir = clean_, 
                  knit_root_dir = root_)

