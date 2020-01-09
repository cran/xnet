## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  fig.width = 6, fig.height = 4,out.width = '49%',fig.align = 'center',
  collapse = TRUE,
  comment = "#>"
)
suppressMessages(library(xnet))

## ----fit a heterogeneous model------------------------------------------------

data(drugtarget)

drugmodel <- tskrr(y = drugTargetInteraction,
                   k = targetSim,
                   g = drugSim,
                   lambda = c(0.01,0.1))

drugmodel

## ----fit a homogeneous model--------------------------------------------------
data(proteinInteraction)

proteinmodel <- tskrr(proteinInteraction,
                      k = Kmat_y2h_sc,
                      lambda = 0.01)

proteinmodel

## ----extract info from a model------------------------------------------------
lambda(drugmodel)  # extract lambda values
lambda(proteinmodel)
dim(drugmodel) # extract the dimensions

protlabels <- labels(proteinmodel)
str(protlabels)

## ----calculate loo values-----------------------------------------------------
loo_drugs_interaction <- loo(drugmodel, exclusion = "interaction",
                       replaceby0 = TRUE)
loo_protein_both <- loo(proteinmodel, exclusion = "both")

## ----calculate loo residuals--------------------------------------------------
loo_resid <- residuals(drugmodel, method = "loo",
                       exclusion = "interaction",
                       replaceby0 = TRUE)
all.equal(loo_resid,
          response(drugmodel) - loo_drugs_interaction )

## ----plot a model, fig.show = 'hold'------------------------------------------
plot(drugmodel, main = "Drug Target interaction")

## ----plot the loo values------------------------------------------------------
plot(proteinmodel, dendro = "none", main = "Protein interaction - LOO",
     which = "loo", exclusion = "both",
     rows = rownames(proteinmodel)[10:20],
     cols = colnames(proteinmodel)[30:35])


## ----plot different color code------------------------------------------------
plot(drugmodel, which = "residuals",
     col = rainbow(20),
     breaks = seq(-1,1,by=0.1))

## ----tune a homogeneous network-----------------------------------------------
proteintuned <- tune(proteinmodel,
                     lim = c(0.001,10),
                     ngrid = 20,
                     fun = loss_auc)
proteintuned

## ----get the grid values------------------------------------------------------
get_grid(proteintuned)

## ----plot grid----------------------------------------------------------------
plot_grid(proteintuned)

## ----residuals tuned model----------------------------------------------------
plot(proteintuned, dendro = "none", main = "Protein interaction - LOO",
     which = "loo", exclusion = "both",
     rows = rownames(proteinmodel)[10:20],
     cols = colnames(proteinmodel)[30:35])

## -----------------------------------------------------------------------------
drugtuned1d <- tune(drugmodel,
                    lim = c(0.001,10),
                    ngrid = 20,
                    fun = loss_auc,
                    onedim = TRUE)
plot_grid(drugtuned1d, main = "1D search")

## ----tune 2d model------------------------------------------------------------
drugtuned2d <- tune(drugmodel,
                     lim = list(k = c(0.001,10), g = c(0.0001,10)),
                     ngrid = list(k = 20, g = 10),
                     fun = loss_auc)

## ----plot grid 2d model-------------------------------------------------------
plot_grid(drugtuned2d, main = "2D search")

## -----------------------------------------------------------------------------
lambda(drugtuned1d)
lambda(drugtuned2d)

## -----------------------------------------------------------------------------
cbind(
  loss = get_loss_values(drugtuned1d)[,1],
  lambda = get_grid(drugtuned1d)$k
)[10:15,]


## ----reorder the data---------------------------------------------------------
idk_test <- c(5,10,15,20,25)
idg_test <- c(2,4,6,8,10)

drugInteraction_train <- drugTargetInteraction[-idk_test, -idg_test]
target_train <- targetSim[-idk_test, -idk_test]
drug_train <- drugSim[-idg_test, -idg_test]

target_test <- targetSim[idk_test, -idk_test]
drug_test <- drugSim[idg_test, -idg_test]

## -----------------------------------------------------------------------------
rownames(target_test)
colnames(drug_test)

## ----train the model----------------------------------------------------------
trained <- tune(drugInteraction_train,
                k = target_train,
                g = drug_train,
                ngrid = 30)

## -----------------------------------------------------------------------------
Newtargets <- predict(trained, k = target_test)
Newtargets[, 1:5]

## -----------------------------------------------------------------------------
Newdrugs <- predict(trained, g = drug_test)
Newdrugs[1:5, ]

## -----------------------------------------------------------------------------
Newdrugtarget <- predict(trained, k=target_test, g=drug_test)
Newdrugtarget

## ----create missing values----------------------------------------------------
drugTargetMissing <- drugTargetInteraction
idmissing <- c(10,20,30,40,50,60)
drugTargetMissing[idmissing] <- NA

## -----------------------------------------------------------------------------
imputed <- impute_tskrr(drugTargetMissing,
                        k = targetSim,
                        g = drugSim,
                        verbose = TRUE)
plot(imputed, dendro = "none")

## -----------------------------------------------------------------------------
has_imputed_values(imputed)
which_imputed(imputed)

# Extract only the imputed values
id <- is_imputed(imputed)
predict(imputed)[id]

## -----------------------------------------------------------------------------
rowid <- rowSums(id) > 0
colid <- colSums(id) > 0
plot(imputed, rows = rowid, cols = colid)

