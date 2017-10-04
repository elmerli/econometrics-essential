# 2_descriptives.R
# Maxwell Austensen
# AEM Replication
# NYU Wagner
# 19-12-2016

library(tidyverse)
library(haven)
library(stringr)
library(feather)
library(knitr)
library(broom)
library(sandwich)

load_sample <- function(n){
  read_feather(str_interp("${clean_}sample${n}.feather")) %>% mutate(sample = str_c("sample", n))
}

all_samples <- c(1, 2, 3) %>% map(load_sample)

order_vec <- c("marriage_ended_mean", "marriage_ended_sd", "age_married_mean", "age_married_sd", "firstborn_girl_mean", 
               "firstborn_girl_sd", "n_children_mean", "n_children_sd", "age_birth_mean", "age_birth_sd", "age_mean", 
               "age_sd", "educ_yrs_mean", "educ_yrs_sd", "urban_mean", "urban_sd", "hh_income_std_mean", 
               "hh_income_std_sd", "poverty_status_mean", "poverty_status_sd", "nonwoman_inc_mean", 
               "nonwoman_inc_sd", "woman_inc_mean", "woman_inc_sd", "woman_earn_mean", "woman_earn_sd")

table_top <-
  all_samples %>% 
  bind_rows() %>% 
  group_by(sample) %>% 
  select(marriage_ended, age_married, firstborn_girl, n_children, age_birth, age, educ_yrs, urban, 
         hh_income_std, poverty_status, nonwoman_inc, woman_inc, woman_earn) %>% 
  summarise_all(funs(mean, sd), na.rm = TRUE) %>%
  gather("variable", "value", -sample) %>% 
  spread(sample, value) %>% 
  mutate(variable = ordered(variable, levels = order_vec)) %>% 
  arrange(variable)

obs_row <- data_frame(variable = "Sample Size",
                      sample1 = nrow(all_samples[[1]]),
                      sample2 = nrow(all_samples[[2]]),
                      sample3 = nrow(all_samples[[3]]))

table1 <-  
  table_top %>% 
  bind_rows(obs_row) %>% 
  mutate(sample1 = if_else(str_detect(variable, "age_birth|firstborn_girl"), NA_real_, sample1)) %>% 
  rename(`Ever-Married with Children` = sample1,
         `All Children Live in Household` = sample2,
         `1st Child Born Within 5 Years of 1st Marriage` = sample3)

write_feather(table1, str_c(clean_, "/table1.feather"))
