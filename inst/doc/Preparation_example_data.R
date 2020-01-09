## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----getFiles, eval = FALSE---------------------------------------------------
#  adjAddress <- "http://web.kuicr.kyoto-u.ac.jp/supp/yoshi/drugtarget/nr_admat_dgc.txt"
#  
#  targetAddress <- "http://web.kuicr.kyoto-u.ac.jp/supp/yoshi/drugtarget/nr_simmat_dg.txt"
#  
#  drugTargetInteraction <- as.matrix(
#    read.table(adjAddress, header = TRUE, row.names = 1, sep = "\t")
#  )
#  targetSim <- as.matrix(
#    read.table(targetAddress, header =TRUE, row.names = 1, sep = "\t")
#  )

## ----importKEGG, eval = FALSE-------------------------------------------------
#  library(ChemmineR)
#  importKEGG <- function(ids){
#    sdfset <- SDFset() # creates an empty SDF set
#  
#    # We use the link format for obtaining the data
#    urlp <- "http://www.genome.jp/dbget-bin/www_bget?-f+m+drug+"
#  
#    # Combine everything in an sdfset
#    for(i in ids){
#      url <- paste0(urlp, i)
#      tmp <- as(read.SDFset(url), "SDFset")
#      cid(tmp) <- i
#      sdfset <- c(sdfset, tmp)
#    }
#    return(sdfset)
#  }
#  # Now read the SDF information for all compounds in the research
#  keggsdf <- importKEGG(colnames(drugTargetInteraction))

## ----tanimoto, eval = FALSE---------------------------------------------------
#  # Keep in mind this needs some time to run!
#  drugSim <- sapply(cid(keggsdf),
#                    function(x){
#                      fmcsBatch(keggsdf[x], keggsdf,
#                                au = 0, bu = 0)[,"Tanimoto_Coefficient"]
#                    })

## -----------------------------------------------------------------------------
data(drugtarget)

