#' Search for areas with similar values
#'
#' Searches for areas with similar values to a query.
#'
#' @param x A numeric vector
#' @param y An object of class SpatRaster (terra)
#' @param dist_fun Distance measure used. This function uses the `philentropy::distance` function (run `philentropy::getDistMethods()` to find possible distance measures), `proxy::dist`  in the background.
#' It is also possible to use `"dtw"` (dynamic time warping)
#' @param ... Additional arguments for `philentropy::dist_one_one`, `proxy::dist`, or `dtwclust::dtw_basic`.
#' When `dist_fun = "dtw"` is used, `ndim` should be set to specify how many dimension the input raster time-series has.
#'
#' @return An object of class SpatRaster (terra)
#' @export
#'
#' @examples
#' library(terra)
#' library(sf)
#' ta = rast(system.file("raster/ta_scaled.tif", package = "spquery"))
#' pr = rast(system.file("raster/pr_scaled.tif", package = "spquery"))
#' twor = c(ta, pr)
#' london = st_sf(geom = st_sfc(st_point(c(-0.1, 51.5))), crs = "EPSG:4326")
#' london_vector = as.numeric(extract(twor, london, ID = FALSE))
#'
#' re = spq_search(london_vector, twor, dist_fun = "euclidean")
#' plot(re)
#'
#' #re2 = spq_search(london_vector, twor, dist_fun = "dtw", ndim = 2, norm = "L2")
#' #plot(re2)
spq_search = function(x, y, dist_fun, ...){
  result = terra::app(y, fun = single_dist_fun, y = x, dist_fun = dist_fun, ...)
  return(result)
}

