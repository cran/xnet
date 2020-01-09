## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
library(xnet)

slotsToRmd <- function(class){
  slots <- getSlots(class)
  
  txt <- paste0(" * `",names(slots), "` : object of type **", slots, "**")
  cat(txt, sep = "\n")
}

## ----Create slots tskrrHomogeneous, results='asis', echo = FALSE--------------
slotsToRmd("tskrrHomogeneous")

## ----Create slots tskrrHeterogeneous, results='asis', echo = FALSE------------
slotsToRmd("tskrrHeterogeneous")

## ----Create slots tskrrTune, results='asis', echo = FALSE---------------------
slotsToRmd("tskrrTune")

## ----Create slots tskrrImpute, results='asis', echo = FALSE-------------------
slotsToRmd("tskrrImpute")

