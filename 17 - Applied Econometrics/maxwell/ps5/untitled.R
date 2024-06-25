---
title: "Data Visulization Exercise"
author: "Elmer Zongyang Li"
date: "August 24, 2016"
output: 
  pdf_document:
    highlight: tango
---

```{r chuck-opts, include=FALSE}
knitr::opts_chunk$set(
	echo = TRUE,
	message = FALSE,
	warning = FALSE
)
```


```{r setup}

# Set useful functions

`%S%` <- function(x, y) {
  paste0(x, y)
}

`%notin%` <- Negate(`%in%`)

# Install packages if needed
package_list <- c("knitr", "haven", "labelled", "ICC", "scales", "tidyverse","ggplot2")
new_packages <- package_list[package_list %notin% installed.packages()[,"Package"]]
if(length(new_packages)) install.packages(new_packages)

library(knitr)
library(haven)
library(labelled)
library(ICC)
library(scales)
library(tidyverse)
library(ggplot2)

```