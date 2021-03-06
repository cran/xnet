% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dim.R
\name{dim,tskrr-method}
\alias{dim,tskrr-method}
\alias{dim.tskrr}
\title{Get the dimensions of a tskrr object}
\usage{
\S4method{dim}{tskrr}(x)
}
\arguments{
\item{x}{a \code{\link[=tskrr-class]{tskrr}} object.}
}
\value{
a vector with two values indicating the number of rows
and the number of columns.
}
\description{
These functions allow you to extract the dimensions of a tskrr
object. These dimensions are essentially the dimensions of the
label matrix y.
}
\examples{
data(drugtarget)
mod <- tskrr(drugTargetInteraction, targetSim, drugSim)
dim(mod)
nrow(mod)
ncol(mod)

}
