5: Table 4 - Effect of Divorce on Women's Economic Status
================
Maxwell Austensen
2016-12-11

``` r
sample3 <- read_feather(str_c(clean_, "sample3.feather"))
```

``` r
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
```

``` r
econ_vars <- c("hh_income_std", "poverty_status", "nonwoman_inc", "woman_inc", "woman_earn", "employed", "weeks_worked", "hours_worked")

ols_table <- 
  econ_vars %>% 
  map_df(get_estimates, data = sample3, adj = TRUE) %>% 
  rename(OLS = value)
```

``` r
get_first_stage <- function(formula){
  formula %>% 
    lm(data = sample3) %>% 
    augment() %>% 
    select(.fitted) %>% 
    bind_cols(sample3) %>% 
    mutate(marriage_ended = .fitted) # overwrite variable with predicted version
}
```

``` r
pred_sample3_wald <- get_first_stage("marriage_ended ~ firstborn_girl")

wald_table <- 
  econ_vars %>% 
  map_df(get_estimates, data = pred_sample3_wald, adj = FALSE) %>% 
  rename(WALD = value)
```

``` r
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
```

``` r
table4 <- 
  ols_table %>% 
  left_join(wald_table, by = "variable") %>% 
  left_join(tsls1_table, by = "variable") %>% 
  left_join(tsls2_table, by = "variable")

write_feather(table4, str_c(clean_, "/tables/table4.feather"))

title <- "Table 4: The Effect of Divorce on Female Economic Status and Labor Supply"
knitr::kable(table4, digits = 3, format = "pandoc", caption = title)
```

| variable             |        OLS|      WALD|   TSLS\_1|   TSLS\_2|
|:---------------------|----------:|---------:|---------:|---------:|
| hh\_income\_std\_est |  -1559.456|  4161.710|  4027.692|  3961.431|
| hh\_income\_std\_se  |     19.805|  1927.501|  1927.942|  1880.415|
| poverty\_status\_est |      0.118|     0.026|     0.037|     0.041|
| poverty\_status\_se  |      0.001|     0.094|     0.100|     0.100|
| nonwoman\_inc\_est   |  -9541.262|  2822.744|  2450.293|  1559.082|
| nonwoman\_inc\_se    |     47.913|  4554.152|  4665.815|  4647.110|
| woman\_inc\_est      |   3960.041|  6079.657|  5672.024|  5569.898|
| woman\_inc\_se       |     23.236|  2052.372|  2166.284|  2106.255|
| woman\_earn\_est     |   2639.807|  5369.155|  5053.446|  5161.719|
| woman\_earn\_se      |     21.355|  1865.817|  1975.215|  1915.871|
| employed\_est        |      0.175|     0.480|     0.440|     0.479|
| employed\_se         |      0.002|     0.179|     0.190|     0.185|
| weeks\_worked\_est   |     10.040|    25.765|    24.564|    25.810|
| weeks\_worked\_se    |      0.082|     7.988|     8.511|     8.220|
| hours\_worked\_est   |      9.527|    11.290|    10.220|    10.388|
| hours\_worked\_se    |      0.067|     6.647|     7.095|     6.874|
