# AEM: PS2 - Instrumental Variables
## Maxwell Austensen
## November 2, 2016


### 1

In the first-stage regression of mpg on displacement we see that the coefficient on displacement is statistically significant at the 1% level. The coefficient on displacement is -0.044, which equates to a one standard deviation increase in displacement being associated with 71% of one standard deviation decrease in mpg. This association means that automobiles with greater engine displacement are less fuel efficient. 

Displacement is a strong instrument for mpg. The model's R-squared indicates that 50% of the variation in mpg can be explained by displacement. The critical value of the first-stage F-statistic is 71.41, which is well above the commonly used thresholds used to test for weak instruments of 10 and 24. This means that the squared bias of the coefficient of interest in the IV model exceeds 10% of the squared bias of the coefficient of interest in an OLS model, because the F-statistic is greater than 10. Additionally, because the F-statistic is greater then 24 the actual level of 5% significance test exceeds 15%, meaning that a 5% test falsely rejects the null hypothesis no more than 15% of the time.

While displacement is clearly relevant to mpg, it is less clear whether it can be considered exogenous and satisfy the exclusion restriction. It seems possible that displacement could have an effect on price through mechanisms other than just effecting fuel efficiency - for example through it's effect on horsepower.


### 2

(See log)

### 3

Eventually labor regulations will be used as an instrument for growth in manufacturing to examine spillover effects of manufacturing on service sector. Here it is helpful to first examine some reduced-form regressions of productivity in the service sector on labor regulations directly. In these specifications we see that the association between labor regulations and productivity in the service sector is positive and statistically significant at the 1% level. This hold for each round separately, with the effect being more than twice as large in the later round. When we use the full sample and include both an indicator for the later round and that round interacted with labor regulations we see that the association between labor regulations and productivity in the service sector was greater in the later round and this differential association is statistically significant at the 1% level. Finally, when we include fixed effects for state and 2-digit industry codes, we find that the magnitude of the effect of labor regulations decreases only slightly (as do the other coefficients) and remains positive and statistically significant at the 1% level. 


### 4

In the first specification we see that growth in manufacturing has a significant positive association with productivity in service sector. This association weakens with the inclusion of labor regulation in the specification, and labor regulations is significantly and positively correlated with service sector productivity - as is the interaction of labor regulations on the round 63 indicator. However, when the state and industry fixed effects are included the association between all manufacturing and service sector productivity tips to be negative. Since manufacturing growth is simultaneously determined with growth in the service sector these associations between manufacturing and services productivity cannot be interpreted as a causal relationship. For this reason we use labor regulations to instrument for manufacturing growth in the following instrumental variables specifications.


### 5

In the first-stage of the first instrumental variables specification the r-squared in .18 and the f-statistic is well above the 10 and 24 thresholds discussed above, suggesting that labor regulations is sufficiently relevant as an instrument for growth in manufacturing. And in the second-stage regression for this specification the instrumented manufacturing growth variable has a positive effect on productivity in the service sector of .129 and is statistically significant at the 1% level.

In the first-stage regression of the second specification, when state fixed-effects are added, there is a problem of multicollinearity with the states and the labor regulations instrument because the labor regulations are at state level and are measured at a single time and thus do not vary within states. This prevents us from successfully completing the second stage for this specification.

In the final specification, the first stage instruments growth in manufacturing interacted with the post period with labor regulations interacted with the post period and including the un-interacted labor regulation, manufacturing growth, and post period as well as state and industry fixed effects. In this first-stage we find that the r-squared is quite high, at .83 and the f-statistic is 5464, suggesting that the instrument is relevant and quite strong. In the second stage regression the effect of the instrumented growth in manufacturing interacted with the post period on service sector productivity is 0.086, slightly smaller than in the first instrumental variables specification, but is still statistically significant at the 1% level.