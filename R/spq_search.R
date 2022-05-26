#' Title
#'
#' @param x
#' @param y
#' @param dist_fun
#'
#' @return
#' @export
#'
#' @examples
#' library(terra)
#' library(sf)
#' ta = rast(system.file("raster/ta_scaled.tif", package = "spquery"))
#' pr = rast(system.file("raster/pr_scaled.tif", package = "spquery"))
#' twor = c(ta, pr)
#' london = st_sf(geom = st_sfc(st_point(c(-0.1, 51.5))), crs = "EPSG:4326")
#' london_rast = crop(twor, vect(london))
#' london_vector = as.numeric(values(london_rast))
#'
#' re = spq_search(twor, london_vector, dist_fun = "euclidean")
#' plot(re)
#'
#' #rd = spq_search(twor, london_vector, dist_fun = "dtw")
#' #plot(rd)
#'
#' #rd2 = spq_search(twor, matrix(london_vector, ncol = 2), dist_fun = "dtw")
#' #plot(rd2)
spq_search = function(x, y, dist_fun){
  if (dist_fun %in% philentropy::getDistMethods()){
    calc_fun = function(x, y){
      philentropy::dist_one_one(x, y, method = dist_fun, testNA = FALSE)
    }
  } else if (dist_fun == "dtw"){
    if (is.vector(y)){
      calc_fun = function(x, y){
        if (!all(is.na(x))){
          x = as.vector(x)
          rr = dtw::dtw(x, y)
          rr$distance
        } else {
          NA
        }
      }
    } else {
      calc_fun = function(x, y){
        if (!all(is.na(x))){
          x = as.vector(x)
          rr = dtw::dtw(matrix(x, nrow = nrow(y)), y)
          rr$distance
        } else {
          NA
        }
      }
    }
  }
  result = terra::app(x, calc_fun, y)
  return(result)
}

