# Search for areas with similar values

Searches for areas with similar values to a query.

## Usage

``` r
spq_search(x, y, dist_fun, ...)
```

## Arguments

- x:

  A numeric vector

- y:

  An object of class SpatRaster (terra)

- dist_fun:

  Distance measure used. This function uses the
  [`philentropy::distance`](https://drostlab.github.io/philentropy/reference/distance.html)
  function (run
  [`philentropy::getDistMethods()`](https://drostlab.github.io/philentropy/reference/getDistMethods.html)
  to find possible distance measures), `proxy::dist` in the background.
  It is also possible to use `"dtw"` (dynamic time warping)

- ...:

  Additional arguments for
  [`philentropy::dist_one_one`](https://drostlab.github.io/philentropy/reference/dist_one_one.html),
  `proxy::dist`, or
  [`dtwclust::dtw_basic`](https://rdrr.io/pkg/dtwclust/man/dtw_basic.html).
  When `dist_fun = "dtw"` is used, `ndim` should be set to specify how
  many dimension the input raster time-series has.

## Value

An object of class SpatRaster (terra)

## Examples

``` r
library(terra)
library(sf)
ta = rast(system.file("raster/ta_scaled.tif", package = "spquery"))
pr = rast(system.file("raster/pr_scaled.tif", package = "spquery"))
twor = c(ta, pr)
london = st_sf(geom = st_sfc(st_point(c(-0.1, 51.5))), crs = "EPSG:4326")
london_vector = as.numeric(extract(twor, london, ID = FALSE))

re = spq_search(london_vector, twor, dist_fun = "euclidean")
plot(re)


#re2 = spq_search(london_vector, twor, dist_fun = "dtw", ndim = 2, norm = "L2")
#plot(re2)
```
