2: Table 1 - Descriptives
================
Maxwell Austensen
2016-12-11

``` r
load_sample <- function(n){
  read_feather(str_interp("${clean_}sample${n}.feather")) %>% mutate(sample = str_c("sample", n))
}
```

``` r
all_samples <- c(1, 2, 3) %>% map(load_sample)
```

``` r
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
  summarise_all(funs(mean, sd)) %>%
  gather("variable", "value", -sample) %>% 
  spread(sample, value) %>% 
  mutate(variable = ordered(variable, levels = order_vec)) %>% 
  arrange(variable)
```

``` r
obs_row <- data_frame(variable = "Sample Size",
                      sample1 = nrow(all_samples[[1]]),
                      sample2 = nrow(all_samples[[2]]),
                      sample3 = nrow(all_samples[[3]]))
```

``` r
table1 <-  
  table_top %>% 
  bind_rows(obs_row) %>% 
  rename(`Ever-Married with Children` = sample1,
         `All Children Live in Household` = sample2,
         `1st Child Born Within 5 Years of 1st Marriage` = sample3)

write_feather(table1, str_c(clean_, "/tables/table1.feather"))

title <- "Table 1: Descriptive Statistics"
knitr::kable(table1, digits = 2, format.args = list(big.mark = ','), format = "pandoc", caption = title)
```

| variable              |  Ever-Married with Children|  All Children Live in Household|  1st Child Born Within 5 Years of 1st Marriage|
|:----------------------|---------------------------:|-------------------------------:|----------------------------------------------:|
| marriage\_ended\_mean |                        0.25|                            0.21|                                           0.20|
| marriage\_ended\_sd   |                        0.43|                            0.40|                                           0.40|
| age\_married\_mean    |                       19.94|                           20.11|                                          20.03|
| age\_married\_sd      |                        2.15|                            2.14|                                           2.13|
| firstborn\_girl\_mean |                          NA|                            0.49|                                           0.49|
| firstborn\_girl\_sd   |                          NA|                            0.50|                                           0.50|
| n\_children\_mean     |                        2.18|                            2.03|                                           2.08|
| n\_children\_sd       |                        1.08|                            0.93|                                           0.94|
| age\_birth\_mean      |                          NA|                           22.63|                                          22.18|
| age\_birth\_sd        |                          NA|                            3.22|                                           2.68|
| age\_mean             |                       31.41|                           30.64|                                          30.55|
| age\_sd               |                        5.14|                            4.84|                                           4.89|
| educ\_yrs\_mean       |                       12.67|                           12.81|                                          12.75|
| educ\_yrs\_sd         |                        2.10|                            2.09|                                           2.01|
| urban\_mean           |                        0.64|                            0.64|                                           0.64|
| urban\_sd             |                        0.48|                            0.48|                                           0.48|
| hh\_income\_std\_mean |                   18,841.86|                        9,743.93|                                       9,578.46|
| hh\_income\_std\_sd   |                  300,218.78|                        5,531.72|                                       5,394.40|
| poverty\_status\_mean |                        0.08|                            0.07|                                           0.07|
| poverty\_status\_sd   |                        0.27|                            0.26|                                           0.26|
| nonwoman\_inc\_mean   |                   27,441.20|                       18,401.25|                                      18,327.16|
| nonwoman\_inc\_sd     |                  300,075.22|                       12,783.25|                                      12,745.20|
| woman\_inc\_mean      |                    4,610.71|                        4,388.71|                                       4,293.37|
| woman\_inc\_sd        |                    5,949.73|                        5,847.96|                                       5,744.21|
| woman\_earn\_mean     |                    4,018.72|                        3,838.21|                                       3,751.33|
| woman\_earn\_sd       |                    5,428.95|                        5,326.69|                                       5,221.68|
| Sample Size           |                  660,705.00|                      533,903.00|                                     463,821.00|
