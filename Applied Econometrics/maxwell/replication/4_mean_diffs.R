# 4_mean_diffs.R
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

cols <- c("marriage_ended", "age_married", "firstborn_girl", "n_children", "age_birth", "age", "educ_yrs", "urban")

sample <- sample3 %>% select(one_of(cols))

fix_labels <- function(data, old_suffix){
  data %>% 
    mutate(variable = str_replace_all(variable, old_suffix[1], "_one"),
           variable = str_replace_all(variable, old_suffix[2], "_two"))  
}

means_left <-
  sample %>% 
  group_by(marriage_ended) %>% 
  summarise_all(funs(mean, sd)) %>% 
  gather("variable", "value", -marriage_ended) %>% 
  mutate(marriage_ended = if_else(marriage_ended == 0, "Never-divorced", "Ever-divorced")) %>% 
  spread(marriage_ended, value) %>% 
  fix_labels(c("_mean", "_sd"))

means_right <-
  sample %>% 
  group_by(firstborn_girl) %>% 
  summarise_all(funs(mean, sd)) %>% 
  gather("variable", "value", -firstborn_girl) %>% 
  mutate(firstborn_girl = if_else(firstborn_girl == 0, "Firstborn Boy", "Firstborn Girl")) %>% 
  spread(firstborn_girl, value) %>% 
  fix_labels(c("_mean", "_sd"))

diff_means <- function(p, data, group){
  f <- str_interp("${p} ~ ${group}")
  
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
    filter(term != "(Intercept)") %>% 
    transmute(var = p,
              est = estimate,
              se = robust_se) %>% 
    gather("stat", "value", -var) %>% 
    unite(variable, var, stat) %>% 
    rename(Difference = value)
}

diffs_left <- 
  cols[cols != "marriage_ended"] %>% 
  map_df(diff_means, data = sample, group = "marriage_ended") %>% 
  fix_labels(c("_est", "_se"))

diffs_right <- 
  cols[cols != "firstborn_girl"] %>% 
  map_df(diff_means, data = sample, group = "firstborn_girl") %>% 
  fix_labels(c("_est", "_se"))

order_vec <- c("marriage_ended_one", "marriage_ended_two", "age_married_one", "age_married_two", 
               "firstborn_girl_one", "firstborn_girl_two", "n_children_one", "n_children_two", 
               "age_birth_one", "age_birth_two", "age_one", "age_two", "educ_yrs_one", 
               "educ_yrs_two", "urban_one", "urban_two")

table_left <- left_join(means_left, diffs_left, by = "variable")
table_right <- left_join(means_right, diffs_right, by = "variable")

left_obs <- sample %>% group_by(marriage_ended) %>% count()
right_obs <- sample %>% group_by(firstborn_girl) %>% count()

obs_row <- data_frame(variable = "Sample Size",
                     `Never-divorced` = left_obs[[1, 2]],
                     `Ever-divorced` = left_obs[[2, 2]],
                     Difference_divorce = nrow(sample),
                     `Firstborn Girl` = right_obs[[1, 2]],
                     `Firstborn Boy` = right_obs[[2, 2]],
                     Difference_firstborn = nrow(sample))

table3 <- 
  full_join(table_left, table_right, by = "variable", suffix = c("_divorce", "_firstborn")) %>% 
  select(variable, `Never-divorced`, `Ever-divorced`, Difference_divorce, 
        `Firstborn Girl`, `Firstborn Boy`, Difference_firstborn) %>% 
  mutate(variable = ordered(variable, levels = order_vec)) %>% 
  arrange(variable) %>% 
  bind_rows(obs_row)
  
write_feather(table3, str_c(clean_, "/table3.feather"))