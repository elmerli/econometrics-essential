# 1_samples.R
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

# load function to assign poverty threshold
source("get_pov_threshold_1990.R")

raw <- read_stata(str_c(raw_, "usa_00005.dta")) %>% zap_labels()

names(raw) <- names(raw) %>% str_to_lower()

mothers <- raw %>%
  group_by(serial) %>% # Create vars requiring info on all household members (eg. standardized household income)
  mutate(hh_adults = sum(age >= 18, na.rm = TRUE),
         hh_children = sum(age < 18, na.rm = TRUE),
         hh_head_65p = if_else(pernum == 1, if_else(age >= 65, 1, 0), NA_real_) %>% sum(na.rm = TRUE),
         inc_adjuster = (hh_adults + (0.7 * hh_children)) ^ 0.7,
         hh_income = if_else(hhincome == 9999999, NA_real_, hhincome),
         hh_income_std = if_else(is.na(hh_income), NA_real_, hh_income / inc_adjuster)) %>% 
  ungroup() %>% 
  filter(bpl %>% between(1, 56), # US born (inc'l us territories etc.)
         race == 1, # white
         sex == 2, # female
         age %>% between(21, 40), # age 21-40
         marrno %>% between(1, 2), # ever married
         agemarr %>% between(17, 26), # married age 17-26
         chborn %>% between(2, 13), # ever child
         marst %>% between(1, 4), # ever married but not widow
         qage == 0, # not allocated: age
         qmarrno == 0, # not allocated: number of marriages
         qmarst == 0, # not allocated: current marital status
         qagemarr== 0, # not allocated: age at first marriage
         qchborn == 0, # not allocated: number of chilren ever born
         qrelate == 0, # not allocated: relation to household head
         qsex == 0) # not allocated: sex

children <- raw %>% 
  filter(momloc != 0,
         stepmom == 0) %>% 
  group_by(serial, momloc, age, birthqtr) %>% 
  mutate(twin = ifelse(n() > 1, 1, 0)) %>%
  group_by(serial, momloc) %>% 
  arrange(serial, momloc, desc(age), birthqtr) %>% 
  filter(row_number() == 1) %>% # keep only one child per mother
  ungroup()

names(children) <- names(children) %>% str_c("_c")

sample1 <- left_join(mothers, children, by = c("serial" = "serial_c", "pernum" = "momloc_c")) %>%
  filter(is.na(qage_c) | qage_c == 0, # not allocated: child's age
         is.na(qsex_c) | qsex_c == 0, # not allocated: child's sex
         is.na(qrelate_c) | qrelate_c == 0, # not allocated: child's relation to head of household
         is.na(qbirthmo_c) | qbirthmo_c == 0, # not allocated: child's birth month
         is.na(momrule_c) | momrule_c %>% between(1, 2)) %>% 
  mutate(marriage_ended = if_else(marst %in% c(3, 4) | marrno == 2, 1, 0),
         firstborn_girl = if_else(sex_c == 2, 1, 0),
         educ_yrs = if_else(higrade < 4, 0, higrade - 3),
         age_birth = age - age_c,
         age_married = agemarr,
         marital_status = if_else(marst %in% c(1, 2) & marrno == 2, 1, 0),
         urban = if_else(metarea == 0, 0, 1),
         n_children = if_else(chborn <= 1, 0, chborn - 1),
         n_children_hh = nchild,
         hh_income_1990 = hh_income * 1.72,
         pov_threshold_1990 = pmap_dbl(list(hh_adults, hh_children, hh_head_65p), get_pov_treshold_1990),
         poverty_status = if_else(hh_income_1990 < pov_threshold_1990, 1, 0),
         woman_inc = if_else(inctot == 9999999, NA_real_, if_else(inctot == -9995, -9900, inctot)),
         nonwoman_inc = hh_income - woman_inc,
         woman_earn = if_else(incwage %in% c(999999, 999998), NA_real_, incwage),
         employed = if_else(empstat == 1, 1, 0),
         weeks_worked = wkswork1,
         hours_worked = uhrswork,
         state_birth = bpl,
         state_current = statefip) %>%
  select(serial,
         pernum,
         perwt,
         hh_adults,
         hh_children,
         hh_head_65p,
         state_birth,
         state_current,
         marriage_ended,
         firstborn_girl,
         educ_yrs,
         age_birth,
         age_married,
         marital_status,
         urban,
         n_children,
         n_children_hh,
         hh_income_std,
         hh_income,
         hh_income_1990,
         pov_threshold_1990,
         poverty_status,
         nonwoman_inc,
         woman_inc,
         woman_earn,
         employed,
         weeks_worked,
         hours_worked,
         age,
         age_c,
         twin_c)

sample2 <- sample1 %>% 
  filter(n_children == n_children_hh, 
         age_c < 18, 
         twin_c != 1)

sample3 <- sample2 %>% 
  mutate(marr_len = age - age_married,
         marr_yr_born = marr_len - age_c) %>% 
  filter(marr_yr_born %>% between(0, 5)) %>%
  select(-marr_len, - marr_yr_born)


rm(raw, mothers, children)

write_feather(sample1, str_c(clean_, "sample1.feather"))
write_feather(sample2, str_c(clean_, "sample2.feather"))
write_feather(sample3, str_c(clean_, "sample3.feather"))
