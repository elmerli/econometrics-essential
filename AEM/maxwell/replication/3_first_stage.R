# 3_first_stage.R
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

first_stage_df <- 
  sample3 %>% 
  mutate(`Education Level: <12 years` = if_else(educ_yrs < 12, 1, 0),
         `Education Level: 12 years` = if_else(educ_yrs == 12, 1, 0),
         `Education Level: 13-15 years` = if_else(between(educ_yrs, 13, 15), 1, 0),
         `Education Level: 16+ years` = if_else(educ_yrs >= 16, 1, 0),
         `Age at First Marriage: <20 years old` = if_else(age_married < 20, 1, 0),
         `Age at First Marriage: 20+ years old` = if_else(age_married >= 20, 1, 0),
         `Age at First Birth: <22 years old` = if_else(age_birth < 22, 1, 0),
         `Age at First Birth: 22+ years old` = if_else(age_birth >= 22, 1, 0))

make_table <- function(name, formula){
  if(name == "firstborn_girl"){
    obs <- data_frame(Observations = nrow(first_stage_df))
    mod <- first_stage_df %>% lm(formula, data = .)
  } else {
    filtered <- first_stage_df %>% filter_(str_interp("`${name}` == 1"))
    obs <- data_frame(Observations = nrow(filtered))
    mod <- filtered %>% lm(formula, data = .)
  }
  
  label <- data_frame(label = name)
  
  est <- 
    mod %>% 
    tidy() %>% 
    filter(term == "firstborn_girl") %>% 
    select(Coefficient = estimate)
  
  f_stat <- 
    mod %>% 
    anova() %>% 
    tidy() %>% 
    filter(term == "firstborn_girl") %>% 
    select(`F-Statistic` = statistic)
  
  df <- bind_cols(label, est, f_stat, obs)
  return(df)
}

cols <- c("firstborn_girl", "Education Level: <12 years", "Education Level: 12 years", "Education Level: 13-15 years", 
          "Education Level: 16+ years", "Age at First Marriage: <20 years old", "Age at First Marriage: 20+ years old", 
          "Age at First Birth: <22 years old", "Age at First Birth: 22+ years old")

adj_formula <- "marriage_ended ~ firstborn_girl + age + age_birth + age_married + educ_yrs + I(age^2) + I(age_married^2) + I(age_birth^2) + I(educ_yrs^2) + age*educ_yrs + age_married*educ_yrs + age_birth*educ_yrs + urban + factor(state_birth) + factor(state_current)"

unadjusted <- map_df(cols, make_table, formula = "marriage_ended ~ firstborn_girl")
adjusted <- map_df(cols, make_table, formula = adj_formula)

table2 <- 
  unadjusted %>% 
  inner_join(adjusted, by = c("label", "Observations"), suffix = c("_unadj", "_adj")) %>% 
  mutate(label = if_else(label == "firstborn_girl", "Overall Effect: Firstborn Girl", label)) %>% 
  select(label, contains("_unadj"), contains("_adj"), Observations)

write_feather(table2, str_c(clean_, "/table2.feather"))