# 6_divorce_effect_by_age.R
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

ols_full <- sample3 %>% mutate(oldest_lt12 = if_else(age_c < 12, 1, 0))
ols_lt12 <- ols_full %>% filter(oldest_lt12 == 1)
ols_ge12 <- ols_full %>% filter(oldest_lt12 == 0)

get_first_stage <- function(df, f){
    lm(formula = f, data = df) %>% 
    augment() %>% 
    select(.fitted) %>% 
    bind_cols(df) %>% 
    mutate(marriage_ended = .fitted) # overwrite variable with predicted version
}

covariates <- " + age + age_birth + age_married + educ_yrs + I(age^2) + I(age_married^2) + I(age_birth^2) + I(educ_yrs^2) + age*educ_yrs + age_married*educ_yrs + age_birth*educ_yrs + urban + factor(state_birth) + factor(state_current)"

first_stage_formula <- str_interp("marriage_ended ~ firstborn_girl ${covariates}")

tsls_full <- ols_full %>% get_first_stage(first_stage_formula)
tsls_lt12 <- ols_full %>% filter(oldest_lt12 == 1) %>% get_first_stage(first_stage_formula)
tsls_ge12 <- ols_full %>% filter(oldest_lt12 == 0) %>% get_first_stage(first_stage_formula)

get_estimates <- function(p, data){
  f <- str_interp("${p} ~ marriage_ended ${covariates}")

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

get_table_col <- function(df){
  map_df(econ_vars, get_estimates, data = df)
}

econ_vars <- c("hh_income_std", "poverty_status", "nonwoman_inc", "woman_inc", "woman_earn", "employed", "weeks_worked", "hours_worked")

ols_cols <- list(ols_full, ols_lt12, ols_ge12) %>% map(get_table_col)

ols_table <-
  ols_cols[[1]] %>% 
  left_join(ols_cols[[2]], by = "variable") %>% 
  left_join(ols_cols[[3]], by = "variable") %>% 
  rename(`Entire Sample` = value.x,
         `Oldest Child <12` = value.y,
         `Oldest Child 12+` = value)


tsls_cols <- list(tsls_full, tsls_lt12, tsls_ge12) %>% map(get_table_col)

tsls_table <-
  tsls_cols[[1]] %>% 
  left_join(tsls_cols[[2]], by = "variable") %>% 
  left_join(tsls_cols[[3]], by = "variable") %>% 
  rename(`Entire Sample` = value.x,
         `Oldest Child <12` = value.y,
         `Oldest Child 12+` = value)

get_f_stat <- function(df){
  df %>%
    lm(first_stage_formula, data = .) %>% 
    anova() %>% 
    tidy() %>% 
    filter(term == "firstborn_girl") %>% 
    select(statistic) %>% 
    .[[1]]
}

f_stat_row <- data_frame(variable = "F-statistic from first stage",
                        `Entire Sample` = get_f_stat(ols_full),
                        `Oldest Child <12` = get_f_stat(ols_lt12),
                        `Oldest Child 12+` = get_f_stat(ols_ge12))

obs_row <- data_frame(variable = "Sample Size",
                      `Entire Sample` = nrow(ols_full),
                      `Oldest Child <12` = nrow(ols_lt12),
                      `Oldest Child 12+` = nrow(ols_ge12))

ols_row <- data_frame(variable = "OLS")
tsls_row <- data_frame(variable = "TSLS")

table5 <- list(ols_row, ols_table, tsls_row, tsls_table, f_stat_row, obs_row) %>% bind_rows()

write_feather(table5, str_c(clean_, "/table5.feather"))