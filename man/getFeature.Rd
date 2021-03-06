% Generated by roxygen2 (4.1.1.9000): do not edit by hand
% Please edit documentation in R/getFeature.R
\name{getFeature}
\alias{getFeature}
\title{Get details for a given feature}
\usage{
getFeature(featureID = NULL)
}
\arguments{
\item{featureID}{A the featureID as a string}
}
\value{
A list containing the JSON object returned by the NBN Gateway.
}
\description{
Given the featureID (an integer), this function get details
of the taxon from the NBN Gateway. These include the label (name),
feature type, etc. If the feature is a \code{GridSquare} then
the information includes the bounding box coordinates.
}
\examples{
\dontrun{
 t <- getFeature("97479")
 t['label']  ## [1] "SN413499"
}
}
\author{
Stuart Ball, JNCC \email{stuart.ball@jncc.gov.uk}
}
\seealso{
\code{\link{getOccurrences}}
}

