% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/minimumdistance_functions.R
\name{distance}
\alias{distance}
\alias{distance_cm}
\alias{distance_cm1}
\alias{and}
\alias{distance_cm2}
\alias{distance_cm_mod1}
\alias{distance_cm_mod2}
\title{Minimum Distance Functions}
\usage{
distance_cm(WW, tail, ei, scale = 1)

distance_cm_mod1(WW, tail, ei, scale = 1)

distance_cm_mod2(WW, tail, ei, scale = 1)
}
\arguments{
\item{WW}{a vector or tibble (data.frame) with one column containing the
positive valued sample}

\item{tail}{tail parameter \eqn{\beta} of the Mittag-Leffler distribution}

\item{ei}{extremal index / weighting \eqn{\theta}}

\item{scale}{scale parameter \eqn{\sigma}}
}
\description{
Functions that calculate the Cramer-von Mises distance (with modifications)
between the empirical distribution function (e.c.d.f.) of a positive valued sample \code{WW}
and a mixture distribution with the dirac measure in zero and Mittag-Leffler distribution
as parts.
The sample \code{WW} may be return times of events of interests.
}
\details{
The cumulative distribution function (c.d.f.) of the mixture distribution is given as
\deqn{F_{\beta,\theta,\sigma}(x)=(1-\theta)\cdot\text{I}_{[0,\infty)}
(x)+\theta \cdot F^*_{\beta,\theta,\sigma}(x),}
where \eqn{F^*_{\beta,\theta,\sigma}} is the c.d.f. of the Mittag-Leffler distribution
with tail-parameter \eqn{\beta <= 1} and sclae parameter scale parameter
\eqn{\sigma* = \theta^{-1/\beta}\cdot \sigma > 0}
(short notation \eqn{ML(\beta,\sigma*)}).
The Cramer-von Mises distance between the e.c.d.f. \eqn{F_{n}} of \eqn{WW_1,\dots,WW_n}
and the mixture distribution is then defined as
\deqn{\Delta^{[CM]}(F_{n},F_{\beta,\theta,\sigma})
=\int\limits_0^\infty(F_{n}(x)-F_{\beta,\theta,\sigma}(x))^2
dF_{\beta,\theta,\sigma}(x)
}
\deqn{
=\frac{1}{n}\sum\limits_{i=1}^n
\bigg(
\frac{i-\frac{1}{2}}{n}
-F_{\beta,\theta,\sigma}(t_{(i+1)})
\bigg)^2 +
\frac{1}{12n^2}+\frac{2}{3}(1-\theta)^3
}
where \eqn{n=}\code{length(WW)}.
The function \code{distance_cm_mod1} and \code{distance_cm_mod2}
calculate two modified version of the Cramer-von Mises distance
\deqn{
\Delta^{[CMmod1]}(F_{n},F_{\beta,\theta,\sigma})
=\int\limits_0^\infty(F_{n}(x)-F_{\beta,\theta,\sigma}(x))^2
dF^*_{\beta,\theta,\sigma}(x)
}
\deqn{
=\frac{1}{\theta}\frac{1}{n}\sum\limits_{i=1}^n
\bigg(
\frac{i-\frac{1}{2}}{n}
-F_{\beta,\theta,\sigma}(t_{(i+1)})
\bigg)^2 +
\frac{1}{12n^2}\frac{1}{\theta}+\frac{1}{3}\frac{(1-\theta)^3}{\theta}
}
and
\deqn{
\Delta^{[CMmod2]}(F_{n},F_{\beta,\theta,\sigma})
=\int\limits_0^\infty(\max\lbrace F_{n}(x),1-\theta\rbrace
-F_{\beta,\theta,\sigma}(x))^2
dF^*_{\beta,\theta,\sigma}(x)
}
\deqn{
=\frac{1}{\theta^3}\frac{1}{n}\sum\limits_{i=
\lceil n(1-\theta)\rceil+1}^n
\bigg(
\frac{i-\frac{1}{2}}{n}
-F_{\beta,\theta,\sigma}(t_{(i+1)})
\bigg)^2 +
\frac{n-\lceil n(1-\theta)\rceil}{12n^3\theta^3}
}
\deqn{
-\frac{(n(1-\theta)^3)-\lceil n(1-\theta)\rceil^3}
{3n^3\theta^3}
+
\frac{(n(1-\theta))^2-\lceil n(1-\theta)\rceil^2}
{n^2\theta^3}
F_{\beta,\theta,\sigma}(t_{(\lceil n(1-\theta)\rceil +1)})
}
\deqn{
-\frac{n(1-\theta)-\lceil n(1-\theta)\rceil}{n\theta^3}
F_{\beta,\theta,\sigma}(t_{(\lceil n(1-\theta)\rceil +1)})^2
}
respectively.
}
