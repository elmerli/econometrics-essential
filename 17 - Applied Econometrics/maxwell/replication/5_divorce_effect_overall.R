# 5_divorce_effect_overall.R
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

sample3 <- read_feather(str_c(clean_, "sample3.feather"))

get_estimates <- function(p, data, adj, extra_adj = FALSE){
  covariates <- " + age + age_birth + age_married + educ_yrs + I(age^2) + I(age_married^2) + I(age_birth^2) + I(educ_yrs^2) + age*educ_yrs + age_married*educ_yrs + age_birth*educ_yrs + urban + factor(state_birth) + factor(state_current)"
  
  if(adj){
    if(extra_adj){
      f <- str_interp("${p} ~ marriage_ended ${covariates} + n_children + marital_status")
    } else {
      f <- str_interp("${p} ~ marriage_ended ${covariates}")
    }
  } else {
    f <- str_interp("${p} ~ marriage_ended")
  }

  mod <- lm(formula = f, data = data)

  # Robust stanadard errors (replicating Stata's robust option)
  robust_se <- 
    mod %>% 
    vcovHC(type = "HC1") %>% 
    diag() %>% 
    sqrt() %>% 
    .[[2]]

  mod %>% 
    tidy() %>% 
    filter(term == "marriage_ended") %>% 
    transmute(var = p,
              est = estimate,
              se = robust_se) %>% 
    gather("stat", "value", -var) %>% 
    unite(variable, var, stat)
}

econ_vars <- c("hh_income_std", "poverty_status", "nonwoman_inc", "woman_inc", "woman_earn", "employed", "weeks_worked", "hours_worked")

ols_table <- 
  econ_vars %>% 
  map_df(get_estimates, data = sample3, adj = TRUE) %>% 
  rename(OLS = value)

get_first_stage <- function(formula){
  formula %>% 
    lm(data = sample3) %>% 
    augment() %>% 
    select(.fitted) %>% 
    bind_cols(sample3) %>% 
    mutate(marriage_ended = .fitted) # overwrite variable with predicted version
}

pred_sample3_wald <- get_first_stage("marriage_ended ~ firstborn_girl")

wald_table <- 
  econ_vars %>% 
  map_df(get_estimates, data = pred_sample3_wald, adj = FALSE) %>% 
  rename(WALD = value)

covariates <- " + age + age_birth + age_married + educ_yrs + I(age^2) + I(age_married^2) + I(age_birth^2) + I(educ_yrs^2) + age*educ_yrs + age_married*educ_yrs + age_birth*educ_yrs + urban + factor(state_birth) + factor(state_current)"

pred_sample3_tsls <- get_first_stage(str_interp("marriage_ended ~ firstborn_girl ${covariates}"))

tsls1_table <- 
  econ_vars %>% 
  map_df(get_estimates, data = pred_sample3_tsls, adj = TRUE) %>% 
  rename(TSLS_1 = value)

tsls2_table <- 
  econ_vars %>% 
  map_df(get_estimates, data = pred_sample3_tsls, adj = TRUE, extra_adj = TRUE) %>% 
  rename(TSLS_2 = value)

table4 <- 
  ols_table %>% 
  left_join(wald_table, by = "variable") %>% 
  left_join(tsls1_table, by = "variable") %>% 
  left_join(tsls2_table, by = "variable")

write_feather(table4, str_c(clean_, "table4.feather"))