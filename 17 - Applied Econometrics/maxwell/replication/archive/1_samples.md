1: Create Samples & Variables
================
Maxwell Austensen
2016-12-10

``` r
# load function to assign poverty threshold
source("get_pov_threshold_99.R")
```

``` r
raw <- read_stata(str_c(raw_, "usa_00005.dta"))
```

``` r
names(raw) <- names(raw) %>% str_to_lower()
raw <- raw %>% zap_labels()
raw %>% select(noquote(order(colnames(raw)))) %>% glimpse()
```

    ## Observations: 11,343,120
    ## Variables: 63
    ## $ age       <dbl> 45, 50, 23, 17, 15, 58, 59, 32, 29, 7, 6, 57, 47, 24...
    ## $ agemarr   <dbl> 19, 25, 0, 0, 0, 22, 27, 21, 18, 0, 0, 20, 17, 0, 0,...
    ## $ ancestr1  <dbl> 50, 32, 32, 32, 32, 32, 22, 291, 939, 295, 295, 26, ...
    ## $ ancestr1d <dbl> 500, 320, 320, 320, 320, 320, 220, 2910, 9390, 2950,...
    ## $ birthqtr  <dbl> 4, 2, 4, 4, 2, 2, 3, 1, 4, 3, 2, 3, 3, 4, 1, 2, 2, 3...
    ## $ bpl       <dbl> 6, 41, 6, 2, 2, 17, 17, 48, 2, 2, 2, 19, 55, 6, 53, ...
    ## $ bpld      <dbl> 600, 4100, 600, 200, 200, 1700, 1700, 4800, 200, 200...
    ## $ chborn    <dbl> 3, 0, 0, 0, 0, 3, 0, 0, 3, 0, 0, 0, 6, 0, 0, 2, 2, 0...
    ## $ classwkr  <dbl> 2, 2, 2, 2, 0, 2, 2, 2, 2, 0, 0, 2, 2, 2, 2, 2, 2, 2...
    ## $ classwkrd <dbl> 22, 22, 22, 22, 0, 25, 22, 22, 22, 0, 0, 28, 22, 22,...
    ## $ datanum   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1...
    ## $ empstat   <dbl> 3, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1...
    ## $ empstatd  <dbl> 30, 10, 10, 10, 0, 10, 10, 10, 10, 0, 0, 10, 10, 10,...
    ## $ famsize   <dbl> 5, 5, 5, 5, 5, 2, 2, 4, 4, 4, 4, 4, 4, 4, 4, 1, 1, 2...
    ## $ famunit   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1...
    ## $ ftotinc   <dbl> 55285, 55285, 55285, 55285, 55285, 21620, 21620, 600...
    ## $ gq        <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1...
    ## $ hhincome  <dbl> 55285, 55285, 55285, 55285, 55285, 21620, 21620, 600...
    ## $ hhwt      <dbl> 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, ...
    ## $ higrade   <dbl> 15, 22, 15, 14, 12, 15, 16, 15, 16, 5, 3, 15, 15, 10...
    ## $ higraded  <dbl> 152, 220, 150, 142, 122, 150, 160, 150, 160, 52, 32,...
    ## $ incbus    <dbl> 0, 0, 0, 0, 999999, 0, 0, 0, 0, 999999, 999999, 0, 0...
    ## $ incfarm   <dbl> 0, 0, 0, 0, 999999, 0, 0, 0, 0, 999999, 999999, 0, 0...
    ## $ incinvst  <dbl> 0, 0, 0, 0, 0, 305, 305, 0, 0, 999999, 999999, 0, 0,...
    ## $ incother  <dbl> 0, 5005, 0, 0, 0, 0, 0, 0, 0, 99999, 99999, 0, 0, 95...
    ## $ incss     <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 99999, 99999, 0, 0, 0, 0,...
    ## $ inctot    <dbl> 205, 30010, 12505, 12565, 0, 18310, 3310, 0, 6005, 9...
    ## $ incwage   <dbl> 205, 25005, 12505, 12565, 999999, 18005, 3005, 0, 60...
    ## $ incwelfr  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 99999, 99999, 0, 0, 0, 0,...
    ## $ marrno    <dbl> 1, 1, 0, 0, 0, 2, 2, 1, 1, 0, 0, 2, 2, 0, 0, 2, 1, 2...
    ## $ marst     <dbl> 1, 1, 6, 6, 6, 1, 1, 1, 1, 6, 6, 1, 1, 6, 6, 4, 4, 1...
    ## $ metarea   <dbl> 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, ...
    ## $ metaread  <dbl> 380, 380, 380, 380, 380, 380, 380, 380, 380, 380, 38...
    ## $ momloc    <dbl> 0, 0, 1, 1, 1, 0, 0, 0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 0...
    ## $ momrule   <dbl> 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0...
    ## $ nchild    <dbl> 3, 3, 0, 0, 0, 0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 0, 0, 0...
    ## $ pernum    <dbl> 1, 2, 3, 4, 5, 1, 2, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 1...
    ## $ perwt     <dbl> 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, ...
    ## $ poploc    <dbl> 0, 0, 2, 2, 2, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0...
    ## $ poprule   <dbl> 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0...
    ## $ poverty   <dbl> 501, 501, 501, 501, 501, 448, 448, 82, 82, 82, 82, 5...
    ## $ qage      <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ qagemarr  <dbl> 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ qbirthmo  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ qchborn   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ qmarrno   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 0...
    ## $ qmarst    <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ qrelate   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ qsex      <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ race      <dbl> 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1...
    ## $ raced     <dbl> 100, 100, 100, 100, 100, 100, 100, 700, 100, 100, 10...
    ## $ relate    <dbl> 1, 2, 3, 3, 3, 1, 2, 1, 2, 3, 3, 1, 2, 3, 3, 1, 12, ...
    ## $ related   <dbl> 101, 201, 301, 301, 301, 101, 201, 101, 201, 301, 30...
    ## $ serial    <dbl> 1, 1, 1, 1, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 6...
    ## $ sex       <dbl> 2, 1, 1, 1, 1, 2, 1, 1, 2, 2, 2, 1, 2, 1, 1, 2, 2, 1...
    ## $ sploc     <dbl> 2, 1, 0, 0, 0, 2, 1, 2, 1, 0, 0, 2, 1, 0, 0, 0, 0, 2...
    ## $ statefip  <dbl> 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2...
    ## $ stateicp  <dbl> 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, 81, ...
    ## $ stepmom   <dbl> 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
    ## $ uhrswork  <dbl> 48, 38, 40, 30, 0, 40, 50, 0, 40, 0, 0, 8, 40, 40, 2...
    ## $ wkswork1  <dbl> 5, 52, 52, 52, 0, 48, 50, 0, 25, 0, 0, 52, 48, 52, 1...
    ## $ workedyr  <dbl> 3, 3, 3, 3, 0, 3, 3, 1, 3, 0, 0, 3, 3, 3, 3, 3, 3, 3...
    ## $ year      <dbl> 1980, 1980, 1980, 1980, 1980, 1980, 1980, 1980, 1980...

``` r
mothers <- 
  raw %>%
  group_by(serial) %>% 
  mutate( # Create standardized household income - needs info on all hh members
          hh_adults = sum(age >= 18, na.rm = TRUE),
          hh_children = sum(age < 18, na.rm = TRUE),
          hh_head_65p = if_else(pernum == 1, if_else(age >= 65, 1, 0), NA_real_) %>% sum(na.rm = TRUE),
          inc_adjuster = (hh_adults + (0.7 * hh_children)) ^ 0.7,
          hh_income_std = hhincome / inc_adjuster) %>% 
  ungroup() %>% 
  filter( # restrict sample
          between(bpl, 1, 120), # US born (inc'l us territories etc.)
          race == 1, # white
          sex == 2, # female
          between(age, 21, 40), # age 21-40
          between(marrno, 1, 2), # ever married
          between(agemarr, 17, 26), # married age 17-26
          between(chborn, 2, 13), # ever child
          between(marst, 1, 4), # ever married but not widow
          qage == 0, # not allocated: age
          qchborn == 0, # not allocated: chilren born
          qmarrno == 0, # not allocated: married
          qmarst == 0, # not allocated: marital status
          qagemarr== 0, # not allocated: married age
          qrelate == 0, # not allocated: relation to household head
          qsex == 0) # not allocated: sex
```

``` r
children <-
  raw %>% 
  filter(momloc != 0) %>% 
  group_by(serial, momloc) %>% 
  mutate(children_mom  = n()) %>% # number of mother's children in household
  filter(age == max(age)) %>% # Keep only the oldest (can be multiple oldest if same age in years)
  mutate(max_age = max(age),
         same_qtr = sum(birthqtr == lag(birthqtr), na.rm = TRUE),
         twin1 = if_else(n() > 1, 1, 0), # twin based only on age in years
         twin2 = if_else(same_qtr > 0, 1, 0)) %>% # twin based on age in years and quarter
         # note: "twin" also includes other multiples (eg. triplets) 
  arrange(serial, desc(age), birthqtr) %>% 
  filter(row_number() == 1) %>% # keep only one child if twin
  ungroup()

names(children) <- names(children) %>% str_c("_c")

# children %>% get_dupes(serial, momloc) # no dupes
```

``` r
sample1 <-
  left_join(mothers, children, by = c("serial" = "serial_c", "pernum" = "momloc_c")) %>%
  filter(is.na(qage_c) | qage_c == 0, # not allocated: child's age
         is.na(qsex_c) | qsex_c == 0, # not allocated: child's sex
         is.na(qrelate_c) | qrelate_c == 0, # not allocated: child's relation to head of household
         is.na(qbirthmo_c) | qbirthmo_c == 0) %>% # not allocated: child's birth month
  filter(# bpl <= 56,
         # bpl %in% c(1:56, 110),
         raced == 100) %>%
  mutate(marriage_ended = if_else(marst %in% c(3, 4) | marrno == 2, 1, 0),
         firstborn_girl = if_else(sex_c == 2, 1, 0),
         educ_yrs = if_else(higrade < 4, 0, higrade - 3),
         age_birth = age - age_c,
         age_married = agemarr,
         marital_status = if_else(marst %in% c(1, 2) & marrno == 2, 1, 0),
         urban = if_else(metarea == 0, 0, 1),
         n_children = if_else(chborn <= 1, 0, chborn - 1),
         children_mom = children_mom_c,
         hh_income = hhincome,
         hh_income_99 = hh_income * 2.314,
         pov_threshold_99 = pmap_dbl(list(hh_adults, hh_children, hh_head_65p), get_pov_treshold_99),
         poverty_status = if_else(hh_income_99 < pov_threshold_99, 1, 0),
         nonwoman_inc = hhincome - inctot,
         woman_inc = inctot,
         woman_earn = incwage,
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
         nchild,
         children_mom,
         hh_income_std,
         hh_income,
         hh_income_99,
         pov_threshold_99,
         poverty_status,
         nonwoman_inc,
         woman_inc,
         woman_earn,
         employed,
         weeks_worked,
         hours_worked,
         chborn,
         age,
         age_c,
         twin1_c,
         twin2_c)

# get_dupes(sample1, serial) # no dupes

# Paper results: 662,204
nrow(sample1)
```

    ## [1] 660705

``` r
sample2 <- 
  sample1 %>% 
  filter(n_children == children_mom, 
         age_c < 18, 
         twin2_c != 1)

# Paper results: 535,887
nrow(sample2)
```

    ## [1] 533903

``` r
sample3 <-
  sample2 %>% 
  mutate(marr_len = age - age_married,
         marr_yr_born = marr_len - age_c) %>% 
  filter(between(marr_yr_born, 0, 5)) %>%
  select(-marr_len, - marr_yr_born)

# Paper results: 465,595
nrow(sample3)
```

    ## [1] 463821

``` r
write_feather(sample1, str_c(clean_, "sample1.feather"))
write_feather(sample2, str_c(clean_, "sample2.feather"))
write_feather(sample3, str_c(clean_, "sample3.feather"))
```
