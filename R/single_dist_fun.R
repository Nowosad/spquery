single_dist_fun = function(x, y, dist_fun, ndim, ...){
  if (dist_fun %in% philentropy::getDistMethods()){
    calc_fun = philentropy::dist_one_one(x, y, method = dist_fun, testNA = FALSE, ...)
  } else if (requireNamespace("proxy", quietly = TRUE) && dist_fun %in% names(summary(proxy::pr_DB)$names)) {
    calc_fun = proxy_dist_one_one(x, y, method = dist_fun, ...)
  } else if (dist_fun == "dtw"){
    calc_fun = dtw_multidim(x, y, ndim = ndim, ...)
  }
  return(calc_fun)
}

compare_dist_fun = function(x, dist_fun, ...){
  y = x[((length(x)/2) + 1):length(x)]
  x = x[1:(length(x)/2)]
  single_dist_fun(x, y, dist_fun = dist_fun, ...)
}

proxy_dist_one_one = function(x, y, method, ...){
  mat = rbind(x, y)
  as.vector(proxy::dist(mat, method = method,
                        auto_convert_data_frames = FALSE, ...))
}
# norm = "L2", step.pattern = dtw::symmetric2
dtw_multidim = function(x, y, ndim, ...){
  if (any(is.na(c(x, y)))){
    return(NA)
  } else {
    mat1 = matrix(unlist(x), ncol = ndim)
    mat2 = matrix(unlist(y), ncol = ndim)
    dtwclust::dtw_basic(mat1, mat2, ...)
  }
}
