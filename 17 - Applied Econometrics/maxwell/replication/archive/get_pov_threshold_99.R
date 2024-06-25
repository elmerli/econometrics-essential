# From: https://usa.ipums.org/usa/volii/poverty.shtml

get_pov_treshold_99 <- function(hh_adults, hh_children, hh_head_65p){
  if(hh_adults + hh_children == 1){
    if(hh_head_65p == 0){
      8667
    } else if(hh_head_65p == 1){
      7990
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 2){
    if(hh_head_65p == 0){
      if(hh_children == 0){
        11156
      } else if(hh_children == 1){
        11483
      } else {
        NA_real_
      }
    } else if(hh_head_65p == 1){
      if(hh_children == 0){
        10070
      } else if(hh_children == 1){
        11440
      } else {
        NA_real_
      }
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 3){
    if(hh_children == 0){
      13032
    } else if(hh_children == 1){
      13410
    } else if(hh_children == 2){
      13423
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 4){
    if(hh_children == 0){
      17184
    } else if(hh_children == 1){
      17465
    } else if(hh_children == 2){
      16895
    } else if(hh_children == 3){
      16954
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 5){
    if(hh_children == 0){
      20723
    } else if(hh_children == 1){
      21024
    } else if(hh_children == 2){
      20380
    } else if(hh_children == 3){
      19882
    } else if(hh_children == 4){
      19578
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 6){
    if(hh_children == 0){
      23835
    } else if(hh_children == 1){
      23930
    } else if(hh_children == 2){
      23436
    } else if(hh_children == 3){
      22964
    } else if(hh_children == 4){
      22261
    } else if(hh_children == 5){
      21845
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 7){
    if(hh_children == 0){
      27425
    } else if(hh_children == 1){
      27596
    } else if(hh_children == 2){
      27006
    } else if(hh_children == 3){
      26895
    } else if(hh_children == 4){
      25828
    } else if(hh_children == 5){
      24934
    } else if(hh_children == 6){
      23953
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children == 8){
    if(hh_children == 0){
      30673
    } else if(hh_children == 1){
      30944
    } else if(hh_children == 2){
      30387
    } else if(hh_children == 3){
      29899
    } else if(hh_children == 4){
      29206
    } else if(hh_children == 5){
      28327
    } else if(hh_children == 6){
      27412
    } else if(hh_children == 7){
      27180
    } else {
      NA_real_
    }
  } else if(hh_adults + hh_children >= 9){
    if(hh_children == 0){
      36897
    } else if(hh_children == 1){
      37076
    } else if(hh_children == 2){
      36583
    } else if(hh_children == 3){
      36169
    } else if(hh_children == 4){
      35489
    } else if(hh_children == 5){
      34554
    } else if(hh_children == 6){
      33708
    } else if(hh_children == 7){
      33499
    } else if(hh_children >= 8){
      32208
    }
  } else {
    NA_real_
  }
}