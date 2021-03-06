#' Leave-one-out cross-validation for tskrr
#'
#' Perform a leave-one-out cross-validation for two-step kernel
#' ridge regression based on the shortcuts described in Stock et al, 2018.
#' (\url{http://doi.org/10.1093/bib/bby095}).
#'
#' @details The parameter \code{exclusion} defines what is left out.
#' The value "interaction" means that a single interaction is removed.
#' In the case of a homogeneous model, this can be interpreted as the
#' removal of the interaction between two edges. The values "row" and
#' "column" mean that all interactions for a row edge resp. a column
#' edge are removed. The value "both" removes all interactions for
#' a row and a column edge.
#'
#' In the case of a homogeneous model, "row" and "column" don't make sense
#' and will be replaced by "both" with a warning. This can be interpreted
#' as removing vertices, i.e. all interactions between one edge and
#' all other edges. Alternatively one can use "edges" to remove edges and
#' "vertices" to remove vertices. In the case of a homogeneous model,
#' the setting "edges" translates to "interaction", and "vertices"
#' translates to "both". For more information, see Stock et al. (2018).
#'
#' Replacing by 0 only makes sense when \code{exclusion = "interaction"} and the
#' label matrix contains only 0 and 1 values. The function checks whether
#' the conditions are fulfilled and if not, returns an error.
#'
#' @param x an object of class \code{\link[xnet:tskrr-class]{tskrr}} or
#' \code{\link{linearFilter}}.
#' @param exclusion a character value with possible values "interaction",
#' "row", "column", "both" for heterogeneous models, and "edges", "vertices",
#' "interaction" or "both" for homogeneous models.
#' Defaults to "interaction". See details.
#' @param replaceby0 a logical value indicating whether the interaction
#' should be simply removed (\code{FALSE}) or replaced by 0 (\code{TRUE}).
#' @param ... arguments passed to methods.
#' See Details.
#'
#' @return a numeric matrix with the leave-one-out predictions for
#' the model.
#'
#' @examples
#' data(drugtarget)
#'
#' mod <- tskrr(drugTargetInteraction, targetSim, drugSim,
#'              lambda = c(0.01,0.01))
#'
#' delta <- loo(mod, exclusion = 'both') - response(mod)
#' delta0 <- loo(mod, replaceby0 = TRUE) - response(mod)
#'
#' @rdname loo
#' @export
setMethod("loo",
          "tskrrHeterogeneous",
          function(x,
                   exclusion = c("interaction","row","column","both"),
                   replaceby0 = FALSE){

            exclusion <- match.arg(exclusion)


            if(replaceby0){
              if(exclusion != "interaction")
                stop("replaceby0 only makes sense when exclusion is set to 'interaction'.")

              if(any(match(x@y, c(0,1), 0L ) == 0))
                stop("replaceby0 only makes sense when the response has 0/1 values.")
            }

            Hk <- hat(x, "row")
            Hg <- hat(x, "column")

            if(exclusion == "interaction"){

              out <- if(replaceby0)
                loo.i0(x@y, Hk, Hg, x@pred)
              else
                loo.i(x@y, Hk, Hg, x@pred)

            } else if(exclusion == "row"){

              out <- loo.r(x@y, Hk, Hg)

            } else if(exclusion == "column"){

              out <- loo.c(x@y, Hk, Hg)

            } else {

              out <- loo.b(x@y, Hk, Hg)
            }
          dimnames(out) <- unname(labels(x))
          return(out)
          })

#' @rdname loo
#' @export
setMethod("loo",
          "tskrrHomogeneous",
          function(x,
                   exclusion = c("edges","vertices","interaction","both"),
                   replaceby0 = FALSE){

            exclusion <- match.arg(exclusion)

            # Translate edges and vertices
            if(exclusion %in% c("interaction","both"))
              exclusion <- switch(exclusion,
                                  interaction = "edges",
                                  both = "vertices")

            symm <- symmetry(x)
            if(replaceby0){
              if(exclusion != "edges")
                stop("replaceby0 only makes sense when exclusion is set to 'edges'.")


              if(symm == "symmetric" && any(match(x@y, c(0,1), 0L ) == 0))
                stop("replaceby0 only makes sense when the response has 0/1 values.")
              else if(symm == "skewed" && any(match(x@y, c(-1,0,1), 0L ) == 0))
                stop("replaceby0 only makes sense when the response has -1/0/1 values.")
            }

            Hk <- hat(x)

            if(exclusion == "edges"){
              loofun <- .getloo_homogeneous("edges",
                                           replaceby0,
                                           symm)
              out <- loofun(x@y, Hk, x@pred)
            } else {
              out <- loo.v(x@y, Hk)
            }
            dimnames(out) <- unname(labels(x))
            return(out)
          })

#' @rdname loo
#' @export
setMethod("loo",
          "linearFilter",
          function(x, replaceby0 = FALSE){

            if(replaceby0 && any(match(x@y, c(0,1), 0L ) == 0))
              stop("replaceby0 only makes sense when the response has 0/1 values.")

            if(replaceby0){
              loo.i0.lf(x@y, x@alpha, x@pred)
            } else {
              loo.i.lf(x@y, x@alpha, x@pred)
            }
          })
