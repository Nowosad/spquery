# Compares values between two rasters

Compares values between two rasters based on a given distance measure.

## Usage

``` r
spq_compare(x, y, dist_fun, ...)
```

## Arguments

- x:

  An object of class SpatRaster (terra)

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
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE
ta = rast(system.file("raster/ta_scaled.tif", package = "spquery"))
pr = rast(system.file("raster/pr_scaled.tif", package = "spquery"))

re = spq_compare(ta, pr, dist_fun = "jensen-shannon")
plot(re)

```
