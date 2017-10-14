6: Table 5 - Divorce Effect by Firstborn Age
================
Maxwell Austensen
2016-12-11

``` r
sample3 <- read_feather(str_c(clean_, "sample3.feather"))
```

``` r
ols_full <- sample3 %>% mutate(oldest_lt12 = if_else(age_c < 12, 1, 0))
ols_lt12 <- ols_full %>% filter(oldest_lt12 == 1)
ols_ge12 <- ols_full %>% filter(oldest_lt12 == 0)
```

``` r
get_first_stage <- function(df, f){
    lm(formula = f, data = df) %>% 
    augment() %>% 
    select(.fitted) %>% 
    bind_cols(df) %>% 
    mutate(marriage_ended = .fitted) # overwrite variable with predicted version
}
```

``` r
covariates <- " + age + age_birth + age_married + educ_yrs + I(age^2) + I(age_married^2) + I(age_birth^2) + I(educ_yrs^2) + age*educ_yrs + age_married*educ_yrs + age_birth*educ_yrs + urban + factor(state_birth) + factor(state_current)"

first_stage_formula <- str_interp("marriage_ended ~ firstborn_girl ${covariates}")

tsls_full <- ols_full %>% get_first_stage(first_stage_formula)
tsls_lt12 <- ols_full %>% filter(oldest_lt12 == 1) %>% get_first_stage(first_stage_formula)
tsls_ge12 <- ols_full %>% filter(oldest_lt12 == 0) %>% get_first_stage(first_stage_formula)
```

``` r
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
```

``` r
get_table_col <- function(df){
  map_df(econ_vars, get_estimates, data = df)
}
```

``` r
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
```

``` r
get_f_stat <- function(df){
  df %>%
    lm(first_stage_formula, data = .) %>% 
    anova() %>% 
    tidy() %>% 
    filter(term == "firstborn_girl") %>% 
    select(statistic) %>% 
    .[[1]]
}
```

``` r
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
```

``` r
table5 <- list(ols_row, ols_table, tsls_row, tsls_table, f_stat_row, obs_row) %>% bind_rows()

write_feather(table5, str_c(clean_, "/tables/table5.feather"))

knitr::kable(table5, digits = 3)
```

| variable                     |  Entire Sample|  Oldest Child &lt;12|  Oldest Child 12+|
|:-----------------------------|--------------:|--------------------:|-----------------:|
| OLS                          |             NA|                   NA|                NA|
| hh\_income\_std\_est         |      -1559.456|            -1401.169|         -1841.029|
| hh\_income\_std\_se          |         19.805|               23.831|            35.305|
| poverty\_status\_est         |          0.118|                0.130|             0.096|
| poverty\_status\_se          |          0.001|                0.002|             0.002|
| nonwoman\_inc\_est           |      -9541.262|            -8714.193|        -11124.915|
| nonwoman\_inc\_se            |         47.913|               57.169|            86.399|
| woman\_inc\_est              |       3960.041|             3786.477|          4327.861|
| woman\_inc\_se               |         23.236|               27.008|            43.538|
| woman\_earn\_est             |       2639.807|             2606.585|          2739.863|
| woman\_earn\_se              |         21.355|               25.267|            39.066|
| employed\_est                |          0.175|                0.197|             0.133|
| employed\_se                 |          0.002|                0.002|             0.003|
| weeks\_worked\_est           |         10.040|               10.952|             8.497|
| weeks\_worked\_se            |          0.082|                0.101|             0.139|
| hours\_worked\_est           |          9.527|               10.443|             8.020|
| hours\_worked\_se            |          0.067|                0.084|             0.114|
| TSLS                         |             NA|                   NA|                NA|
| hh\_income\_std\_est         |       4027.692|             6589.015|          1129.516|
| hh\_income\_std\_se          |       1927.942|             3077.906|          2334.594|
| poverty\_status\_est         |          0.037|               -0.058|             0.133|
| poverty\_status\_se          |          0.100|                0.168|             0.110|
| nonwoman\_inc\_est           |       2450.293|            13336.576|         -9191.257|
| nonwoman\_inc\_se            |       4665.815|             7223.051|          5970.859|
| woman\_inc\_est              |       5672.024|             1346.669|         10073.244|
| woman\_inc\_se               |       2166.284|             3376.033|          2731.524|
| woman\_earn\_est             |       5053.446|             1581.252|          8511.861|
| woman\_earn\_se              |       1975.215|             3109.567|          2447.235|
| employed\_est                |          0.440|                0.375|             0.498|
| employed\_se                 |          0.190|                0.314|             0.212|
| weeks\_worked\_est           |         24.564|               14.359|            35.297|
| weeks\_worked\_se            |          8.511|               13.882|             9.849|
| hours\_worked\_est           |         10.220|                0.624|            20.235|
| hours\_worked\_se            |          7.095|               11.712|             7.972|
| F-statistic from first stage |         52.777|               20.372|            36.338|
| Sample Size                  |     463821.000|           325519.000|        138302.000|
