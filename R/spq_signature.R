#' Title
#'
#' @param x An object of class SpatRaster (terra)
#' @param dists The radius of the circle (in units of the crs)
#' @param fun Function to summarize the values for a given `dists`.
#'   The default, `mean`, returns the mean of the values inside specified windows.
#' @param ...
#'
#' @return An object of class SpatRaster (terra)
#' @export
#'
#' @examples
#' library(terra)
#' x = rast(system.file("raster/ta_scaled.tif", package = "spquery"))
#' xs = spq_signature(x, dists = c(0.1, 0.2, 0.3), fun = mean)
#' plot(xs)
spq_signature = function(x, w, fun = mean, ...){
    all_results = focal_list(x, w, fun, ...)
    all_results = do.call(c, all_results)
    return(all_results)
}

focal_list = function(x, w, fun, ...){
    output = vector("list", length(w))
    for(i in seq_along(w)){
        output[[i]] = terra::focal(x, w = w[[i]], fun = fun, ...)
    }
    return(output)
}