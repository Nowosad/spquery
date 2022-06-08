#' Compares values between two rasters
#'
#' Compares values between two rasters based on a given distance measure.
#'
#' @param x An object of class SpatRaster (terra)
#' @param y An object of class SpatRaster (terra)
#' @param dist_fun Distance measure used. This function uses the `philentropy::distance` function in the background. Run `philentropy::getDistMethods()` to find possible distance measures.
#' @param ... Additional arguments for the `philentropy::dist_one_one` function
#'
#' @return An object of class SpatRaster (terra)
#' @export
#'
#' @examples
#' library(terra)
#' library(sf)
#' ta = rast(system.file("raster/ta_scaled.tif", package = "spquery"))
#' pr = rast(system.file("raster/pr_scaled.tif", package = "spquery"))
#'
#' re = spq_compare(ta, pr, dist_fun = "jensen-shannon")
#' plot(re)
#'
spq_compare = function(x, y, dist_fun, ...){
  xy = c(x, y)
  result = terra::app(xy, compare_dist_fun, dist_fun = dist_fun, ...)
  return(result)
}


