#' Find the distance to the closest feature-space values in another raster
#'
#' For each cell in `x`, finds the minimum distance to any complete feature
#' vector in `y`. Raster geometry is not used in the calculation; the layers
#' of each raster represent the dimensions of a feature vector.
#'
#' @param x An object of class SpatRaster (terra). Its cells define the query
#'   feature vectors and its geometry is retained in the result.
#' @param y An object of class SpatRaster (terra). Its cells define the
#'   reference feature vectors.
#' @param dist_fun Distance measure used. This function uses the same distance
#'   measures as [spq_search()], including measures from `philentropy`,
#'   `proxy`, and dynamic time warping through `dtwclust`. Set
#'   `dist_approx = TRUE` with `dist_fun = "euclidean"` to use an approximate
#'   Euclidean nearest-neighbour search.
#' @param dist_approx Logical; use an approximate nearest-neighbour method?
#'   Currently supported for `dist_fun = "euclidean"` only.
#' @param eps Non-negative, dimensionless relative approximation tolerance for
#'   approximate Euclidean search. For example, `eps = 0.1` permits a result
#'   approximately up to 10 percent farther than the exact nearest distance.
#'   Larger values can be faster but less accurate. The default, zero, requests
#'   an exact nearest-neighbour search. It has no raster or feature-value units.
#' @param output Character string specifying the output: `"distance"` returns
#'   the distance to the closest feature vector, `"id"` returns the 1-based
#'   cell ID of the closest cell in `y`, and `"all"` returns both as layers.
#' @param block_size Number of rows from `x` to process at once.
#' @param progress Logical; show a progress bar while processing `x`?
#' @param ... Additional arguments for the selected distance backend. When
#'   `dist_fun = "dtw"`, `ndim` must be supplied.
#'
#' @return An object of class SpatRaster (terra) with the same geometry as
#'   `x`. It has one layer for `output = "distance"` or `output = "id"`, and
#'   two layers, named `distance` and `id`, for `output = "all"`.
#' @export
#'
#' @examples
#' library(terra)
#' ta = rast(system.file("raster/ta_scaled.tif", package = "spquery"))
#' pr = rast(system.file("raster/pr_scaled.tif", package = "spquery"))
#'
#' re = spq_proximity(
#'   ta, pr, dist_fun = "euclidean", dist_approx = TRUE
#' )
#' plot(re)
spq_proximity <- function(
  x,
  y,
  dist_fun,
  output = c("distance", "id", "all"),
  block_size = 100,
  progress = TRUE,
  dist_approx = FALSE,
  eps = 0,
  ...
) {
  output <- match.arg(output)
  if (!inherits(x, "SpatRaster") || !inherits(y, "SpatRaster")) {
    stop("x and y must be SpatRaster objects")
  }
  if (terra::nlyr(x) != terra::nlyr(y)) {
    stop("x and y must have the same number of layers")
  }
  if (
    length(block_size) != 1 ||
      !is.numeric(block_size) ||
      is.na(block_size) ||
      block_size < 1 ||
      block_size != as.integer(block_size)
  ) {
    stop("block_size must be a positive integer")
  }
  if (
    length(dist_approx) != 1 || !is.logical(dist_approx) || is.na(dist_approx)
  ) {
    stop("dist_approx must be TRUE or FALSE")
  }
  if (
    length(eps) != 1 ||
      !is.numeric(eps) ||
      is.na(eps) ||
      eps < 0
  ) {
    stop("eps must be a single non-negative number")
  }
  if (isTRUE(dist_approx) && !identical(dist_fun, "euclidean")) {
    stop(
      "dist_approx = TRUE is currently supported for dist_fun = 'euclidean' only"
    )
  }
  use_approx <- identical(dist_fun, "euclidean") && isTRUE(dist_approx)
  if (use_approx && !requireNamespace("RANN", quietly = TRUE)) {
    stop(
      "approximate Euclidean search requires the RANN package; ",
      "install it with install.packages('RANN')"
    )
  }

  reference <- terra::values(y, mat = TRUE)
  complete_reference <- stats::complete.cases(reference)
  if (!any(complete_reference)) {
    stop("y has no complete feature vectors")
  }
  reference <- reference[complete_reference, , drop = FALSE]


  distances_result <- rep(NA_real_, terra::ncell(x))
  ids_result <- rep(NA_real_, terra::ncell(x))
  nrows <- terra::nrow(x)
  block_size <- as.integer(block_size)
  first_rows <- seq.int(1, nrows, by = block_size)
  progress_bar <- NULL
  if (isTRUE(progress)) {
    progress_bar <- utils::txtProgressBar(
      min = 0,
      max = length(first_rows),
      style = 3
    )
  }

  terra::readStart(x)
  on.exit(
    {
      terra::readStop(x)
      if (!is.null(progress_bar)) {
        close(progress_bar)
      }
    },
    add = TRUE
  )

  for (block in seq_along(first_rows)) {
    first_row <- first_rows[block]
    rows <- min(block_size, nrows - first_row + 1)
    query <- terra::readValues(x, row = first_row, nrows = rows, mat = TRUE)
    complete <- stats::complete.cases(query)
    distances <- rep(NA_real_, nrow(query))
    ids <- rep(NA_real_, nrow(query))

    if (any(complete)) {
      query_complete <- query[complete, , drop = FALSE]
      if (use_approx) {
        nearest <- euclidean_approx_proximity(
          query_complete,
          reference,
          eps = eps
        )
        distances[complete] <- nearest$distance
        ids[complete] <- reference_cell_ids(
          nearest$id,
          complete_reference
        )
      } else {
        nearest <- lapply(
          which(complete),
          function(i) {
            distances <- vapply(
              seq_len(nrow(reference)),
              function(j) {
                as.numeric(single_dist_fun(
                  query[i, ],
                  reference[j, ],
                  dist_fun = dist_fun,
                  ...
                ))
              },
              numeric(1)
            )
            id <- which.min(distances)
            c(distance = distances[id], id = id)
          }
        )
        nearest <- do.call(rbind, nearest)
        distances[complete] <- nearest[, "distance"]
        ids[complete] <- reference_cell_ids(
          nearest[, "id"],
          complete_reference
        )
      }
    }

    first_cell <- (first_row - 1) * terra::ncol(x) + 1
    last_cell <- first_cell + nrow(query) - 1
    distances_result[first_cell:last_cell] <- distances
    ids_result[first_cell:last_cell] <- ids
    if (!is.null(progress_bar)) {
      utils::setTxtProgressBar(progress_bar, block)
    }
  }

  result <- terra::rast(x, nlyrs = if (output == "all") 2 else 1)
  if (output == "id") {
    result <- terra::setValues(result, ids_result)
    names(result) <- "id"
  } else if (output == "all") {
    result <- terra::setValues(result, cbind(distances_result, ids_result))
    names(result) <- c("distance", "id")
  } else {
    result <- terra::setValues(result, distances_result)
    names(result) <- "distance"
  }
  result
}

reference_cell_ids <- function(index, complete_reference) {
  # Reconstruct only the selected original cell IDs; no full numeric ID
  # vector is retained between blocks.
  as.double(which(complete_reference)[index])
}

euclidean_approx_proximity <- function(query, reference, eps) {
  nearest <- RANN::nn2(
    data = reference,
    query = query,
    k = 1,
    eps = eps,
    searchtype = "standard"
  )
  list(
    distance = nearest$nn.dists[, 1],
    id = nearest$nn.idx[, 1]
  )
}
