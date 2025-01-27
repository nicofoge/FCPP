#'Optim function for known scale parameter
#'
#'An optimization function, that estimates the tail
#'parameter and the extremal index of
#'the mixture distribution consisting of a
#'dirac measure in zero and a Mittag Leffler distribution.
#'The function is using a grid of multiple initialization values
#'for the extremal index and the tail parameter.
#'
#'
#' @param WW  vector of inter-exceedance times
#' @param ptail  P(JJ > u) = k/n (number of exceedances over number of observations)
#' @param distance_fct  R-function calculating the distance between the asymptotic and empirical cdf
#' @param rho known parameter
#' @param t vector of starting values in \eqn{(0,1]} for the tail parameter
#' @param e vector of starting values in \eqn{[0,1]} for the extremal index
#' @param a_tail lowest possible estimation for the tail parameter
#' @param a_ei lowest possible estimation for the extremal index
#' @param method algorithm that is used by \code{stats::optim} to minimize the
#' distance function
#'
#' @details
#' All combinations of \code{e} and \code{t} are used as starting values
#' to compute the minimum of \code{distance_fct}. The function is minimized
#' using \code{stats::optim} and every combination \code{e} and \code{t}.
#' The parameters corresponding to the lowest value found, are returned
#' as estimation for \code{ei} and \code{tail}.
#'
#' @return
#' A tibble containing the estimation for
#' the extremal index and the tail parameter. \code{value} is the minimum
#' found
#' value of the choosen distance.
#'

#
#
#
#'@name optim
#' @export
optim_bt <- function(WW, distance_fct, ptail, rho,
                                       t = c(0.25,0.55,0.85), e = c(0.25,0.55,0.85),
                                       a_tail = 0.1, a_ei = 0.1, method = "L-BFGS-B") {
  if(is.data.frame(WW) & length(WW) == 1) {
    WW <- dplyr::pull(WW)
  }
  start <- tidyr::crossing(
    t = t,
    e = e
  )
  est <- dplyr::mutate(start,
                       opt = purrr::pmap(list(t, e), function(t., e.) {
                         tryCatch(
                           stats::optim( par = c(t., e.), fn = function(x) {
                             do.call(
                               distance_fct, list(WW = WW, tail = x[1], ei = x[2],
                                                  scale = ptail ^ {-1 / x[1]} * rho)
                             )
                           },
                           lower = c(a_tail, a_ei), upper = c(1, 1),
                           method = method),
                           error = function(x) NA
                         )
                       }),
                       beta = purrr::map_dbl(opt, ~tryCatch(.x$par[1],
                                                            error = function(x) NA )),
                       theta = purrr::map_dbl(opt, ~tryCatch(.x$par[2],
                                                             error = function(x) NA )),
                       value = purrr::map_dbl(opt, ~tryCatch(.x$value,
                                                             error = function(x) NA ))
  )
  est <- dplyr::select(est, -opt)
  est2 <- est[which.min(est$value), ]
  return(est2)
}


#' @rdname optim
#' @export
optim_btr <- function(WW, distance_fct, ptail = NULL, type = 1,
                                            t = c(0.25,0.55,0.85), e = c(0.25,0.55,0.85),
                                            r = NULL, s = NULL, sstar = NULL,
                                            a_tail = 0.1, a_ei = 0.1, method = "L-BFGS-B") {
  # type1: es wird beta, theta und rho geschaetzt
  # type2: es wird beta, theta und sigma geschaetzt
  # type3: es wird beta, theta und sigma^star geschaetzt
  if(is.data.frame(WW) & length(WW) == 1) {
    WW <- dplyr::pull(WW)
  }
  initial <- MittagLeffleR::logMomentEstimator(WW) # for the starting point of rho/sigma/sigmastar
  # initial[2] = sigmastar
  start <- tidyr::crossing(
    t = t,
    e = e
  )
  if(type == 1) {
  if(is.null(ptail)) stop("for type = 1 you need the tail probability ptail")
  if(is.numeric(r)) {
    start <- start |> tidyr::crossing(
      r = r
    )
  } else if(is.numeric(s)) {
    start <- start |> tidyr::crossing(
      s = s
    ) |> dplyr::mutate(
      r = s * ptail ^ {1 / t}
    ) |> dplyr::select(-s)
  } else {
    start <- start |> dplyr::mutate(
      r = initial[2] * (ptail * e) ^ {1 / t}
    )
  }

  est <- dplyr::mutate(start,
                       opt = purrr::pmap(list(t, e, r), function(t., e., r.) {
                         tryCatch(
                           stats::optim( par = c(t., e., r.), fn = function(x) {
                             do.call(
                               distance_fct, list(WW = WW, tail = x[1], ei = x[2],
                                                  scale = ptail ^ {-1 / x[1]} * x[3])
                             )
                           },
                           lower = c(a_tail, a_ei, 0), upper = c(1, 1, Inf),
                           method = method),
                           error = function(x) NA
                         )
                       }),
                       beta = purrr::map_dbl(opt, ~tryCatch(.x$par[1],
                                                            error = function(x) NA )),
                       theta = purrr::map_dbl(opt, ~tryCatch(.x$par[2],
                                                             error = function(x) NA )),
                       rho = purrr::map_dbl(opt, ~tryCatch(.x$par[3],
                                                             error = function(x) NA )),
                       value = purrr::map_dbl(opt, ~tryCatch(.x$value,
                                                             error = function(x) NA ))
  )
  est <- dplyr::select(est, -opt)
  est2 <- est[which.min(est$value), ]
  return(est2)
  }

  if(type == 2) {
    if(is.numeric(s)) {
      start <- start |> tidyr::crossing(
        s = s
      )
    } else if(is.numeric(r) & is.numeric(ptail) & length(ptail) == 1) {
      start <- start |> tidyr::crossing(
        s = r * ptail ^ {-1 / t}
      )
    } else {
      start <- start |> dplyr::mutate(
        s = initial[2] * e ^ {1 / t}
      )
    }

    est <- dplyr::mutate(start,
                         opt = purrr::pmap(list(t, e, s), function(t., e., s.) {
                           tryCatch(
                             stats::optim( par = c(t., e., s.), fn = function(x) {
                               do.call(
                                 distance_fct, list(WW = WW, tail = x[1], ei = x[2], scale = x[3])
                               )
                             },
                             lower = c(a_tail, a_ei, 0), upper = c(1, 1, Inf),
                             method = method),
                             error = function(x) NA
                           )
                         }),
                         beta = purrr::map_dbl(opt, ~tryCatch(.x$par[1],
                                                              error = function(x) NA )),
                         theta = purrr::map_dbl(opt, ~tryCatch(.x$par[2],
                                                               error = function(x) NA )),
                         sigma =  purrr::map_dbl(opt, ~tryCatch(.x$par[3],
                                                                error = function(x) NA )),
                         value = purrr::map_dbl(opt, ~tryCatch(.x$value,
                                                               error = function(x) NA ))
    )
    est <- dplyr::select(est, -opt)
    est2 <- est[which.min(est$value), ]
    return(est2)
  }

  if(type == 3) {
    if(is.numeric(sstar)) {
      start <- start |> tidyr::crossing(
        sstar = sstar
      )
    } else if(is.numeric(s)) {
      start <- start |> tidyr::crossing(
        s = s
      ) |> dplyr::mutate(
        sstar = e ^ {-1 / t} * s
      ) |> dplyr::select(-s)

    } else if(is.numeric(r) & is.numeric(ptail) & length(ptail) == 1) {
      start <- start |> tidyr::crossing(
        r = r
      ) |> dplyr::mutate(
        sstar = (e * ptail) ^ {-1 / t} * r
      ) |> dplyr::select(-r)
    } else {
      start <- start |> dplyr::mutate(
        sstar = initial[2]
      )
    }

    est <- dplyr::mutate(start,
                         opt = purrr::pmap(list(t, e, sstar), function(t., e., sstar.) {
                           tryCatch(
                             stats::optim( par = c(t., e., sstar.), fn = function(x) {
                               do.call(
                                 distance_fct, list(WW = WW, tail = x[1], ei = x[2], scale = x[2] ^ {1 / x[1]} * x[3])
                               )
                             },
                             lower = c(a_tail, a_ei, 0), upper = c(1, 1, Inf),
                             method = method),
                             error = function(x) NA
                           )
                         }),
                         beta = purrr::map_dbl(opt, ~tryCatch(.x$par[1],
                                                              error = function(x) NA )),
                         theta = purrr::map_dbl(opt, ~tryCatch(.x$par[2],
                                                               error = function(x) NA )),
                         sigmastar =  purrr::map_dbl(opt, ~tryCatch(.x$par[3],
                                                                error = function(x) NA )),
                         value = purrr::map_dbl(opt, ~tryCatch(.x$value,
                                                               error = function(x) NA ))
    )
    est <- dplyr::select(est, -opt)
    est2 <- est[which.min(est$value), ]
    return(est2)
  }
}
