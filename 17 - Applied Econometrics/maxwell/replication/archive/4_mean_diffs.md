4: Table 3 - Differences in Means
================
Maxwell Austensen
2016-12-11

``` r
sample3 <- read_feather(str_c(clean_, "sample3.feather"))
```

``` r
cols <- c("marriage_ended", "age_married", "firstborn_girl", "n_children", "age_birth", "age", "educ_yrs", "urban")

sample <- sample3 %>% select(one_of(cols))
```

``` r
fix_labels <- function(data, old_suffix){
  data %>% 
    mutate(variable = str_replace_all(variable, old_suffix[1], "_one"),
           variable = str_replace_all(variable, old_suffix[2], "_two"))  
}
```

``` r
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
```

``` r
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
```

``` r
diffs_left <- 
  cols[cols != "marriage_ended"] %>% 
  map_df(diff_means, data = sample, group = "marriage_ended") %>% 
  fix_labels(c("_est", "_se"))

diffs_right <- 
  cols[cols != "firstborn_girl"] %>% 
  map_df(diff_means, data = sample, group = "firstborn_girl") %>% 
  fix_labels(c("_est", "_se"))
```

``` r
order_vec <- c("marriage_ended_one", "marriage_ended_two", "age_married_one", "age_married_two", 
               "firstborn_girl_one", "firstborn_girl_two", "n_children_one", "n_children_two", 
               "age_birth_one", "age_birth_two", "age_one", "age_two", "educ_yrs_one", 
               "educ_yrs_two", "urban_one", "urban_two")

table_left <- left_join(means_left, diffs_left, by = "variable")
table_right <- left_join(means_right, diffs_right, by = "variable")

table3 <- 
  full_join(table_left, table_right, by = "variable", suffix = c("_divorce", "_firstborn")) %>% 
  select(variable, `Never-divorced`, `Ever-divorced`, everything()) %>% 
  mutate(variable = ordered(variable, levels = order_vec)) %>% 
  arrange(variable)
  
write_feather(table3, str_c(clean_, "/tables/table3.feather"))

title <- "Table 3: Differences in Means, by Divorce Status and Firstborn Sex (Ever-Married Mothers)"
knitr::kable(table3, digits = 3, format = "pandoc", caption = title)
```

| variable             |  Never-divorced|  Ever-divorced|  Difference\_divorce|  Firstborn Boy|  Firstborn Girl|  Difference\_firstborn|
|:---------------------|---------------:|--------------:|--------------------:|--------------:|---------------:|----------------------:|
| marriage\_ended\_one |              NA|             NA|                   NA|          0.192|           0.201|                  0.008|
| marriage\_ended\_two |              NA|             NA|                   NA|          0.394|           0.401|                  0.001|
| age\_married\_one    |          20.212|         19.302|               -0.910|         20.037|          20.030|                 -0.007|
| age\_married\_two    |           2.144|          1.905|                0.007|          2.133|           2.127|                  0.006|
| firstborn\_girl\_one |           0.485|          0.498|                0.013|             NA|              NA|                     NA|
| firstborn\_girl\_two |           0.500|          0.500|                0.002|             NA|              NA|                     NA|
| n\_children\_one     |           2.114|          1.966|               -0.148|          2.083|           2.087|                  0.004|
| n\_children\_two     |           0.936|          0.941|                0.003|          0.934|           0.943|                  0.003|
| age\_birth\_one      |          22.416|         21.204|               -1.212|         22.182|          22.173|                 -0.009|
| age\_birth\_two      |           2.681|          2.428|                0.009|          2.677|           2.677|                  0.008|
| age\_one             |          30.499|         30.774|                0.275|         30.550|          30.556|                  0.006|
| age\_two             |           4.960|          4.589|                0.017|          4.894|           4.887|                  0.014|
| educ\_yrs\_one       |          12.835|         12.394|               -0.441|         12.746|          12.751|                  0.005|
| educ\_yrs\_two       |           2.028|          1.914|                0.007|          2.015|           2.012|                  0.006|
| urban\_one           |           0.631|          0.679|                0.048|          0.639|           0.641|                  0.002|
| urban\_two           |           0.483|          0.467|                0.002|          0.480|           0.480|                  0.001|
