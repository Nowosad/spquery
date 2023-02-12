#' Title (TBD)
#'
#' @param x  An object of class SpatRaster (terra)
#' @param window 	A length of the side of a square-shaped block of cells.
#'   Expressed in the numbers of cells, it defines the extent of a local pattern.
#' @param fun Function to summarize the values in a given `window`.
#'   The default, `c`, returns all of the values inside specified windows.
#' @param ... Additional arguments for `terra::extract` or for the specified function
#'
#' @return  An object of class SpatRaster (terra)
#' @export
#'
#' @examples
#' library(terra)
#' x = rast(system.file("raster/ta_scaled.tif", package = "spquery"))
#' xc = spq_collapse(x, window = 5)
#' plot(xc)
spq_collapse = function(x, window, fun = c, ...){
  zone = terra::rast(x, nlyrs = 1, names = "zone")
  zone = terra::aggregate(zone, fact = window)
  terra::values(zone) = seq_len(terra::ncell(zone))
  zonep = terra::as.polygons(zone)
  x = terra::extend(x, zonep)
  z = terra::extract(x, zonep, fun = fun, ID = FALSE, ...)
  result = terra::rast(zone, nlyrs = terra::ncol(z))
  terra::values(result) = z
  names(result) = rep(names(x), each = window^2)
  return(result)
}
