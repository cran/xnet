% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Class_tskrr.R
\name{tskrr-class}
\alias{tskrr-class}
\title{Class tskrr}
\description{
The class tskrr represents a two step kernel ridge regression fitting
object, and is normally generated by the function \code{\link{tskrr}}.
This is a superclass so it should not be instantiated directly.
}
\section{Slots}{

\describe{
\item{\code{y}}{the matrix with responses}

\item{\code{k}}{the eigen decomposition of the kernel matrix for the rows}

\item{\code{lambda.k}}{the lambda value used for k}

\item{\code{pred}}{the matrix with the predictions}

\item{\code{has.hat}}{a logical value indicating whether the kernel hat matrices
are stored in the object.}

\item{\code{Hk}}{the kernel hat matrix for the rows.}

\item{\code{labels}}{a list with two character vectors, \code{k} and
\code{g}, containing the labels for the rows resp. columns. See
\code{\link{tskrrHomogeneous}} and
\code{\link{tskrrHeterogeneous}} for more details.}
}}

\seealso{
the classes \code{\link{tskrrHomogeneous}} and
\code{\link{tskrrHeterogeneous}} for the actual classes.
}
