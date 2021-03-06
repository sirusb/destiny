% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dpt-methods-matrix.r
\docType{methods}
\name{DPT matrix methods}
\alias{DPT matrix methods}
\alias{[.DPT}
\alias{[,DPT,index,index,logicalOrMissing-method}
\alias{[,DPT,index,missing,logicalOrMissing-method}
\alias{[,DPT,missing,index,logicalOrMissing-method}
\alias{[,DPT,missing,missing,logicalOrMissing-method}
\alias{[[,DPT,index,index-method}
\alias{nrow.DPT}
\alias{nrow,DPT-method}
\alias{ncol.DPT}
\alias{ncol,DPT-method}
\alias{dim.DPT}
\alias{dim,DPT-method}
\title{DPT Matrix methods}
\usage{
\S4method{[}{DPT,index,index,logicalOrMissing}(x, i, j, ..., drop = TRUE)

\S4method{[}{DPT,index,missing,logicalOrMissing}(x, i, j, ..., drop = TRUE)

\S4method{[}{DPT,missing,index,logicalOrMissing}(x, i, j, ..., drop = TRUE)

\S4method{[}{DPT,missing,missing,logicalOrMissing}(x, i, j, ..., drop = TRUE)

\S4method{[[}{DPT,index,index}(x, i, j, ...)

\S4method{nrow}{DPT}(x)

\S4method{ncol}{DPT}(x)

\S4method{dim}{DPT}(x)
}
\arguments{
\item{x}{\code{\link{DPT}} object.}

\item{i, j}{\link[=numeric]{Numeric} or \link{logical} index.}

\item{...}{ignored}

\item{drop}{If \code{\link{TRUE}}, coerce result to a vector if it would otherwise have \code{1 \%in\% dim(result)}.}
}
\description{
Treat DPT object as a matrix of cell-by-cell DPT distances.
}
\seealso{
\code{\link{as.matrix.DPT}}
}
