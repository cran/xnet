context("LOO shortcuts")

# Preparation -----------------------------------------------------
dfile <- system.file("testdata","testdata.rda", package = "xnet")

load(dfile)
lambdak <- 0.01
lambdag <- 1.5
mod <- tskrr(Y, K, G, lambda = c(lambdak, lambdag))
eigK <- get_eigen(mod, 'row')
eigG <- get_eigen(mod, 'column')
Hk <- hat(mod, 'row')
Hg <- hat(mod, 'column')
pred <- fitted(mod)

# symmetric network
dfile <- system.file("testdata","testdataH.rda", package = "xnet")
load(dfile)
modh <- tskrr(Yh, Kh, lambda = lambdak)
eigKh <- get_eigen(modh)
Hkh <- hat(modh)
predh <- fitted(modh)

# Skewed network
mods <- tskrr(Ys, Kh, lambda = lambdak)
eigKs <- get_eigen(mods)
Hks <- hat(mods)
preds <- fitted(mods)

# Linear filter
linF <- linear_filter(Y)

# Tests -----------------------------------------------------------

## get_loo_fun ----------------------------------------------------


test_that("get_loo_fun returns the correct function",{

  # Heterogeneous models
  expect_equal(get_loo_fun(mod, 'interaction', replaceby0 = FALSE), loo.i)
  expect_equal(get_loo_fun(mod, 'interaction', replaceby0 = TRUE), loo.i0)
  expect_equal(get_loo_fun(mod,'row'), loo.r)
  expect_equal(get_loo_fun(mod,'column'), loo.c)
  expect_equal(get_loo_fun(mod,'both'), loo.b)

  expect_equal(get_loo_fun(modh,'interaction',
                           replaceby0 = FALSE), loo.e.sym)
  expect_equal(get_loo_fun(mods, 'interaction'), loo.e.skew)
  expect_equal(get_loo_fun(modh,'both'), loo.v)
  expect_equal(get_loo_fun(mods,'both'), loo.v)
  expect_equal(get_loo_fun(modh,'edge',
                           replaceby0 = FALSE), loo.e.sym)
  expect_equal(get_loo_fun(mods, 'edge'), loo.e.skew)
  expect_equal(get_loo_fun(modh,'vertices'), loo.v)
  expect_equal(get_loo_fun(mods,'vertices'), loo.v)
  expect_error(get_loo_fun(modh,'row'))
  expect_error(get_loo_fun(mods,'column',replaceby0 = TRUE))
  # Linear filters
  expect_equal(get_loo_fun(linF), loo.i.lf)
  expect_equal(get_loo_fun(linF, replaceby0 = TRUE), loo.i0.lf)
  # Character values
  expect_equal(get_loo_fun("tskrrHeterogeneous","column"),
               loo.c)
  expect_equal(get_loo_fun("tskrrHeterogeneous","interaction",
                           replaceby0 = TRUE),
               loo.i0)
  expect_equal(get_loo_fun("tskrrHeterogeneous","interaction",
                           replaceby0 = FALSE),
               loo.i)
  expect_equal(get_loo_fun("tskrrHeterogeneous","both",
                           replaceby0 = TRUE),
               loo.b)

  expect_equal(get_loo_fun("tskrrHomogeneous","both",
                           symmetry = "skewed"),
               loo.v)
  expect_equal(get_loo_fun("tskrrHomogeneous","both",
                           symmetry = "symmetric"),
               loo.v)
  expect_equal(get_loo_fun("tskrrHomogeneous","interaction",
                           replaceby0 = TRUE,
                           symmetry = "skewed"),
               loo.e0.skew)
  expect_equal(get_loo_fun("tskrrHomogeneous","interaction",
                           replaceby0 = FALSE,
                           symmetry = "skewed"),
               loo.e.skew)
  expect_equal(get_loo_fun("tskrrHomogeneous","interaction",
                           replaceby0 = TRUE,
                           symmetry = "symmetric"),
               loo.e0.sym)
  expect_equal(get_loo_fun("tskrrHomogeneous","interaction",
                           replaceby0 = FALSE,
                           symmetry = "symmetric"),
               loo.e.sym)

  # Test alternative shortcuts
  expect_equal(get_loo_fun("tskrrHomogeneous","vertices",
                           symmetry = "skewed"),
               loo.v)
  expect_equal(get_loo_fun("tskrrHomogeneous","vertices",
                           symmetry = "symmetric"),
               loo.v)
  expect_equal(get_loo_fun("tskrrHomogeneous","edges",
                           replaceby0 = TRUE,
                           symmetry = "skewed"),
               loo.e0.skew)
  expect_equal(get_loo_fun("tskrrHomogeneous","edges",
                           replaceby0 = FALSE,
                           symmetry = "skewed"),
               loo.e.skew)
  expect_equal(get_loo_fun("tskrrHomogeneous","edges",
                           replaceby0 = TRUE,
                           symmetry = "symmetric"),
               loo.e0.sym)
  expect_equal(get_loo_fun("tskrrHomogeneous","edges",
                           replaceby0 = FALSE,
                           symmetry = "symmetric"),
               loo.e.sym)



  expect_equal(get_loo_fun("linearFilter",replaceby0 = FALSE),
               loo.i.lf)
  expect_equal(get_loo_fun("linearFilter", replaceby0 = TRUE),
               loo.i0.lf)

})

## Test loo errors ------------------------------------------------

test_that("loo processes arguments correctly",{
  expect_error(loo(mod, exclusion = "row", replaceby0 = TRUE),
               regexp = "only makes sense .* 'interaction'")
  expect_error(loo(modh, exclusion = "both", replaceby0 = TRUE),
               regexp = "only makes sense .* 'edges'")
})

Ycont <- Y
Ycont[3,4] <- 2
modcont <- tskrr(Ycont, K, G)
Yhcont <- Yh
Yhcont[3,4] <- Yhcont[4,3] <- 2
modhcont <- tskrr(Yhcont,Kh)
Yscont <- Ys
Yscont[3,4] <- 2
Yscont[4,3] <- -2
modscont <- tskrr(Yscont, Kh)
Lincont <- linear_filter(Ycont)

test_that("Replaceby0 is only used on 0/1 matrices",{
  expect_error(loo(modcont, replaceby0=TRUE),
               "only makes sense .* 0/1 values")
  expect_error(loo(modhcont, replaceby0=TRUE),
               "only makes sense .* 0/1 values")
  expect_error(loo(modscont, replaceby0=TRUE),
               "only makes sense .* -1/0/1 values")
  expect_error(loo(Lincont, replaceby0=TRUE),
               "only makes sense .* 0/1 values")

})

predict_ij <- function(Y,Hk, Hg, i, j){
  (Hk[i,,drop = FALSE] %*% Y %*% Hg[,j,drop = FALSE])
}

## Heterogeneous network -------------------------------------------

test_that("shortcuts bipartite networks work",{

  # Setting I
  looI <- loo(mod)
  looItest <- sapply(seq_len(ncol(Y)),
                     function(y) sapply(seq_len(nrow(Y)),
                                        function(x){Ytilde <- Y
                                        Ytilde[x,y] <- looI[x,y]
                                        predict_ij(Ytilde, Hk, Hg, x, y) }
                                        )
                     )


  expect_equal(unname(looI),looItest)

  # Setting I0
  looI0 <- loo(mod, replaceby0 = TRUE)
  looI0test <- sapply(seq_len(ncol(Y)),
                     function(y) sapply(seq_len(nrow(Y)),
                                        function(x){Ytilde <- Y
                                        Ytilde[x,y] <- 0
                                        predict_ij(Ytilde, Hk, Hg, x, y) }
                     ))

  expect_equal(unname(looI0), looI0test)

  # Setting Row
  looR <- loo(mod, exclusion = "row")
  looRtest <- sapply(seq_len(nrow(Y)), function(i){
    modx <- tskrr(Y[-i,],K[-i,-i],G, lambda = c(lambdak, lambdag))
    predict(modx, K[i,-i, drop = FALSE],G)

  })
  # sapply gives the matrix in a different way.
  expect_equal(unname(looR), t(looRtest))

  # Setting Col
  looC <- loo(mod, exclusion = "column")
  looCtest <- sapply(seq_len(ncol(Y)), function(j){
    modx <- tskrr(Y[, -j], K, G[-j, -j], lambda = c(lambdak,lambdag))
    predict(modx, K, G[j, -j, drop = FALSE])
  })

  expect_equal(unname(looC), looCtest)

  # Setting both
  i <- 3
  j <- 4
  looB <- loo(mod, exclusion = "both")[i,j, drop = FALSE]
  modx <- tskrr(Y[-i, -j], K[-i,-i], G[-j,-j], lambda = c(lambdak,lambdag))
  looBtest <- predict(modx, K[i, -i, drop = FALSE],
                      G[j, -j, drop = FALSE])
  expect_equal(unname(looB), looBtest)

})

## Homogeneous network ---------------------------------------------

test_that("shortcuts homogeneous networks work", {

  # Shortcut for the moment is not tested on the diagonal, as that
  # gives very weird results. Replacement by looE result is maybe
  # not the best way forward.
  looE <- loo(modh)
  looEtest<-  sapply(seq_len(ncol(Yh)),
                     function(y) sapply(seq_len(nrow(Yh)),
                                        function(x){Ytilde <- Yh
                                          Ytilde[x,y] <- looE[x,y]
                                          Ytilde[y,x] <- looE[y,x]
                                          predict_ij(Ytilde, Hkh, Hkh, x, y) }
                     )
  )
  diag(looEtest) <- diag(looE)

  expect_equal(unname(looE),looEtest)

  # setting E0
  looE0 <- loo(modh, replaceby0 = TRUE)
  looE0test <- sapply(seq_len(ncol(Yh)),
                     function(y) sapply(seq_len(nrow(Yh)),
                                        function(x){Ytilde <- Yh
                                        Ytilde[x,y] <- 0
                                        Ytilde[y,x] <- 0
                                        predict_ij(Ytilde, Hkh, Hkh, x, y)
                                        }
                     )
  )

  expect_equal(unname(looE0), looE0test)

  # Setting both

  looV <- loo(modh, exclusion = "both")
  looVtest <- sapply(seq_len(nrow(Yh)), function(i){

    modx <- tskrr(Yh[-i, -i], Kh[-i, -i], lambda = lambdak)
    predict(modx, Kh[i, -i, drop = FALSE], Kh[,-i,drop = FALSE])
  })

  expect_equal(unname(looV), t(looVtest))

})

## Homogeneous networks - skewed ---------------------------------

test_that("shortcuts skewed homogeneous networks work", {

  # Shortcut for the moment is not tested on the diagonal, as that
  # gives very weird results. Replacement by looE result is maybe
  # not the best way forward.
  looE <- loo(mods)
  looEtest <- sapply(seq_len(ncol(Ys)),
                     function(y) sapply(seq_len(nrow(Ys)),
                                        function(x){Ytilde <- Ys
                                        Ytilde[x,y] <- looE[x,y]
                                        Ytilde[y,x] <- looE[y,x]
                                        if(x == y) Ytilde[x,y] else
                                          predict_ij(Ytilde, Hks, Hks, x, y) }
                     )
  )


  expect_equal(unname(looE),looEtest)

  # setting E0
  looE0 <- loo(mods, replaceby0 = TRUE)
  looE0test <- sapply(seq_len(ncol(Ys)),
                      function(y) sapply(seq_len(nrow(Ys)),
                                         function(x){Ytilde <- Ys
                                         Ytilde[x,y] <- 0
                                         Ytilde[y,x] <- 0
                                         predict_ij(Ytilde, Hks, Hks, x, y)
                                         }
                      )
  )

  expect_equal(unname(looE0), looE0test)

  # Setting both

  looV <- loo(mods, exclusion = "both")
  looVtest <- sapply(seq_len(nrow(Ys)), function(i){

    modx <- tskrr(Ys[-i, -i], Kh[-i, -i], lambda = lambdak)
    predict(modx, Kh[i, -i, drop = FALSE], Kh[,-i,drop = FALSE])
  })

  expect_equal(unname(looV), t(looVtest))

})

## Linear filter ---------------------------------------------

alphas <- c(0.4,0.3,0.2,0.1)
linF <- linear_filter(Y, alpha = alphas)
testLOO <- function(Y,alpha){

  nr <- nrow(Y)
  nc <- ncol(Y)

  res <- matrix(NA, nrow = nr, ncol = nc)

  a <- alpha[1] + alpha[2]/nr + alpha[3]/nc + alpha[4]/(nr*nc)

  for(i in seq_len(nr)){
    for(j in seq_len(nc)){

      res[i,j] <-
        (sum(Y[-i,j])*alpha[2]/nr + #column mean minus ith row
        sum(Y[i,-j])*alpha[3]/nc + #row mean minus jth column
        sum(Y[row(Y) != i | col(Y) != j])*alpha[4]/(nr*nc)) /  # mean minus observation
        (1 - a)

      # KEEP IN MIND: Y[-i,-j] drops both ith row and jth column
      # not just the element at row i and column j. This costed
      # you a week Joris, you daft idiot.
    }
  }
  return(res)
}

testLOO0 <- function(Y,alpha){

  res <- matrix(NA, nrow = nrow(Y), ncol = ncol(Y))

  for(i in seq_len(nrow(Y))){
    for(j in seq_len(ncol(Y))){
      Ytilde <- Y
      Ytilde[i,j] <- 0
      res[i,j] <- 0 +
        mean(Ytilde[,j])*alpha[2] + #column mean
        mean(Ytilde[i,])*alpha[3] + #row mean
        mean(Ytilde)*alpha[4]  # mean
    }
  }
  return(res)

}

test_that("shortcuts linear filter work", {
  # Setting I
  looI <- loo(linF)
  expect_equal(looI, testLOO(Y, alphas))

  # Setting I0
  looI0 <- loo(linF, replaceby0 = TRUE)
  expect_equal(looI0,testLOO0(Y, alphas))
})
