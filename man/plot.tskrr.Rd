% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.tskrr.R
\name{plot.tskrr}
\alias{plot.tskrr}
\title{plot a heatmap of the predictions from a tskrr model}
\usage{
\method{plot}{tskrr}(
  x,
  dendro = c("both", "row", "col", "none"),
  which = c("fitted", "loo", "response", "residuals"),
  exclusion = c("interaction", "row", "column", "both"),
  replaceby0 = FALSE,
  nbest = 0,
  rows,
  cols,
  col = rev(heat.colors(20)),
  breaks = NULL,
  legend = TRUE,
  main = NULL,
  xlab = NULL,
  ylab = NULL,
  labRow = NULL,
  labCol = NULL,
  margins = c(5, 5),
  ...
)
}
\arguments{
\item{x}{a tskrr model}

\item{dendro}{a character value indicating whether a dendrogram
should be constructed.}

\item{which}{a character value indicating whether the fitted values,
the leave-one-out values, the original response values  or the
residuals should be plotted.}

\item{exclusion}{if \code{which = "loo"}, this argument is passed to
\code{\link{loo}} for the exclusion settings}

\item{replaceby0}{if \code{which = "loo"}, this argument is passed to
\code{\link{loo}}.}

\item{nbest}{a single integer value indicating the amount of best values
that should be selected. If \code{0}, all data is shown.}

\item{rows}{a numeric or character vector indicating which rows should be
selected from the model.}

\item{cols}{a numeric or character vector indicating which columns should be
selected from the model.}

\item{col}{a vector with colors to be used for plotting}

\item{breaks}{a single value specifying the number of
breaks (must be 1 more than number of colors), or a numeric
vector with the breaks used for the color code. If \code{NULL},
the function tries to find evenly spaced breaks.}

\item{legend}{a logical value indicating whether or not the legend should
be added to the plot.}

\item{main}{a character value with a title for the plot}

\item{xlab}{a character label for the X axis}

\item{ylab}{a character label for the Y axis}

\item{labRow}{a character vector with labels to be used on the rows.
Note that these labels are used as is (possibly reordered to match
the dendrogram). They can replace the labels from the model. Set to
\code{NA} to remove the row labels.}

\item{labCol}{the same as \code{labRow} but then for the columns.}

\item{margins}{a numeric vector with 2 values indicating the margins to
be used for the row and column labels (cfr \code{par("mar")})}

\item{...}{currently ignored}
}
\value{
an invisible list with the following elements:
\itemize{
\item \code{val}: the values plotted
\item \code{ddK}: if a row dendrogram was requested, the row dendrogram
\item \code{ddG}: if a column dendrogram was requested,
the column dendrogram
\item \code{breaks}: the breaks used for the color codes
\item \code{col}: the colors used
}
}
\description{
This function plots a heatmap of the fitted values in a
\code{\link{tskrr}} model. The function is loosely based on
\code{\link{heatmap}}, but uses a different mechanism and adds
a legend by default.
}
\details{
The function can select a part of the model for plotting. Either you
specify \code{rows} and \code{cols}, or you specify \code{nbest}.
If \code{nbest} is specified, \code{rows} and \code{cols} are ignored.
The n highest values are looked up in the plotted values, and only
the rows and columns related to these values are shown then. This
allows for a quick selection of the highest predictions.

Dendrograms are created by converting the kernel matrices to
a distance, using

d(x,y) = K(x,x)^2 + K(y,y)^2 - 2*K(x,y)

with K being the kernel function. The resulting distances are
clustered using \code{\link{hclust}} and converted to a
dendrogram using \code{\link{as.dendrogram}}.
}
\examples{
data(drugtarget)
mod <- tskrr(drugTargetInteraction, targetSim, drugSim)

plot(mod)
plot(mod, dendro = "row", legend = FALSE)
plot(mod, col = rainbow(20), dendro = "none", which = "residuals")
plot(mod, labCol = NA, labRow = NA, margins = c(0.2,0.2))

}
\seealso{
\code{\link{tskrr}}, \code{\link{tune}} and
\code{link{impute_tskrr}} to construct tskrr models.
}
