% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sigmas.r
\docType{class}
\name{Sigmas class}
\alias{Sigmas class}
\alias{Sigmas}
\alias{Sigmas-class}
\alias{Sigmas-methods}
\alias{print,Sigmas-method}
\alias{show,Sigmas-method}
\alias{optimal_sigma,Sigmas-method}
\title{Sigmas Object}
\usage{
Sigmas(...)

\S4method{optimal_sigma}{Sigmas}(object)

\S4method{print}{Sigmas}(x)

\S4method{show}{Sigmas}(object)
}
\arguments{
\item{object, x}{\link{Sigmas} object}

\item{...}{See \dQuote{\strong{Slots}} below}
}
\value{
\code{Sigmas} creates an object of the same class

\code{optimal_sigma} retrieves the numeric value of the optimal sigma or local sigmas
}
\description{
Holds the information about how the \code{sigma} parameter for a \link{DiffusionMap} was obtained,
and in this way provides a plotting function for the \link{find_sigmas} heuristic.
You should not need to create a Sigmas object yourself. Provide \code{sigma} to \link{DiffusionMap} instead or use \link{find_sigmas}.
}
\details{
A Sigmas object is either created by \link{find_sigmas} or by specifying the \code{sigma} parameter to \link{DiffusionMap}.

In the second case, if the \code{sigma} parameter is just a number,
the resulting \code{Sigmas} object has all slots except of \code{optimal_sigma} set to \code{NULL}.
}
\section{Slots}{

\describe{
\item{\code{log_sigmas}}{Vector of length \eqn{m} containing the \eqn{\log_{10}} of the \eqn{\sigma}s}

\item{\code{dim_norms}}{Vector of length \eqn{m-1} containing the average dimensionality \eqn{\langle p \rangle} for the respective kernel widths}

\item{\code{optimal_sigma}}{Multiple local sigmas or the mean of the two global \eqn{\sigma}s around the highest \eqn{\langle p \rangle} (\code{c(optimal_idx, optimal_idx+1L)})}

\item{\code{optimal_idx}}{The index of the highest \eqn{\langle p \rangle}.}

\item{\code{avrd_norms}}{Vector of length \eqn{m} containing the average dimensionality for the corresponding sigma.}
}}

\examples{
data(guo)
sigs <- find_sigmas(guo, verbose = FALSE)
optimal_sigma(sigs)
print(sigs)

}
\seealso{
\code{\link{find_sigmas}}, the function to determine a locally optimal sigma and returning this class
}
