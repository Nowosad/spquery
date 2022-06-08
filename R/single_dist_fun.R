single_dist_fun = function(x, y, dist_fun, ...){
  if (dist_fun %in% philentropy::getDistMethods()){
    calc_fun = philentropy::dist_one_one(x, y, method = dist_fun, testNA = FALSE, ...)
  } else if (requireNamespace("proxy", quietly = TRUE) && dist_fun %in% names(summary(proxy::pr_DB)$names)) {
    calc_fun = proxy_dist_one_one(x, y, method = dist_fun, ...)
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
