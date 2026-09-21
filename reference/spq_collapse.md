# Title (TBD)

Title (TBD)

## Usage

``` r
spq_collapse(x, window, fun = c, ...)
```

## Arguments

- x:

  An object of class SpatRaster (terra)

- window:

  A length of the side of a square-shaped block of cells. Expressed in
  the numbers of cells, it defines the extent of a local pattern.

- fun:

  Function to summarize the values in a given `window`. The default,
  `c`, returns all of the values inside specified windows.

- ...:

  Additional arguments for
  [`terra::extract`](https://rspatial.github.io/terra/reference/extract.html)
  or for the specified function

## Value

An object of class SpatRaster (terra)

## Examples

``` r
library(terra)
#> terra 1.9.50
x = rast(system.file("raster/ta_scaled.tif", package = "spquery"))
xc = spq_collapse(x, window = 5)
plot(xc)
```
