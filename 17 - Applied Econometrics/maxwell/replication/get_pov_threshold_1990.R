# From: https://usa.ipums.org/usa/volii/poverty.shtml
# multiply hhincome by 1.72 to compare 1980 census to these thresholds

get_pov_treshold_1990 <- function(hh_adults, hh_children, hh_head_65p){
  if(hh_adults + hh_children == 1){
    if(hh_head_65p == 0){
      6451
    } else if(hh_head_65p == 1){
      5947
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 2){
    if(hh_head_65p == 0){
      if(hh_children == 0){
        8303
      } else if(hh_children == 1){
        8547
      } else {
        NA_real_
      }
    } else if(hh_head_65p == 1){
      if(hh_children == 0){
        7495
      } else if(hh_children == 1){
        8515
      } else {
        NA_real_
      }
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 3){
    if(hh_children == 0){
      9699
    } else if(hh_children == 1){
      9981
    } else if(hh_children == 2){
      9990
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 4){
    if(hh_children == 0){
      12790
    } else if(hh_children == 1){
      12999
    } else if(hh_children == 2){
      12575
    } else if(hh_children == 3){
      12619
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 5){
    if(hh_children == 0){
      15424
    } else if(hh_children == 1){
      15648
    } else if(hh_children == 2){
      15169
    } else if(hh_children == 3){
      14798
    } else if(hh_children == 4){
      14572
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 6){
    if(hh_children == 0){
      17740
    } else if(hh_children == 1){
      17811
    } else if(hh_children == 2){
      17444
    } else if(hh_children == 3){
      17092
    } else if(hh_children == 4){
      16569
    } else if(hh_children == 5){
      16259
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 7){
    if(hh_children == 0){
      20412
    } else if(hh_children == 1){
      20540
    } else if(hh_children == 2){
      20101
    } else if(hh_children == 3){
      19794
    } else if(hh_children == 4){
      19224
    } else if(hh_children == 5){
      18558
    } else if(hh_children == 6){
      17828
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 8){
    if(hh_children == 0){
      22830
    } else if(hh_children == 1){
      23031
    } else if(hh_children == 2){
      22617
    } else if(hh_children == 3){
      22253
    } else if(hh_children == 4){
      21738
    } else if(hh_children == 5){
      21084
    } else if(hh_children == 6){
      20403
    } else if(hh_children == 7){
      20230
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children >= 9){
    if(hh_children == 0){
      27463
    } else if(hh_children == 1){
      27596
    } else if(hh_children == 2){
      27229
    } else if(hh_children == 3){
      26921
    } else if(hh_children == 4){
      26415
    } else if(hh_children == 5){
      25719
    } else if(hh_children == 6){
      25089
    } else if(hh_children == 7){
      24933
    } else if(hh_children >= 8){
      23973
    }
  } else {
    NA_real_
  }
}