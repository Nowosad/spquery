generate_focal_mats = function(x, d, type, fillNA = FALSE){
  if (type == "donut"){
    d = convert_to_pairs(d)
  }
  if (type == "circle" && length(d) > 1){
    d = as.list(d)
  }
  if (!inherits(d, "list")){
    d = list(d)
  }
  lapply(d, generate_focal_mat, x = x, type = type, fillNA = fillNA)
}

# res_c = generate_focal_mats(x, c(0.1, 0.2), "circle")
# res_r = generate_focal_mats(x, c(0.1, 0.2), "rectangle")
# res_g = generate_focal_mats(x, c(0.05, 0.07), "Gauss")
# res_d = generate_focal_mats(x, c(0.1, 0.2, 0.3), "donut")

# plot(rast(res_d[[1]]))
# plot(rast(res_d[[2]]))
# plot(rast(res_d[[3]]))

convert_to_pairs = function(vec) {
  vec = c(0, vec)
  if (length(vec) == 2) {
    return(list(vec))
  } else {
    pairs = lapply(1:(length(vec) - 1), function(i) {
      c(vec[i], vec[i + 1])
    })
    return(pairs)
  }
}

generate_focal_mat = function(x, d, type, fillNA = FALSE){
  if (type %in% c("circle", "Gauss", "rectangle")){
    return(focalMat(x, d, type, fillNA))
  } else if (type == "donut") {
    return(donutMat(x, d, fillNA))
  } else {
    stop("Invalid type")
  }
}

donutMat = function(x, d, fillNA = FALSE) {
  rs = terra::res(x)
  inner_d = d[[1]]; outer_d = d[[2]]
  # Generate the outer circle matrix
  outer_circle = generate_circle_matrix(rs, outer_d)
  
  if (inner_d == 0){
    donut = outer_circle
  } else {
    # Generate the inner circle matrix
    inner_circle = generate_circle_matrix(rs, inner_d)

    nx = 1 + 2 * floor(outer_d / rs[1])
    ny = 1 + 2 * floor(outer_d / rs[2])
    
    nx_inner = 1 + 2 * floor(inner_d / rs[1])
    ny_inner = 1 + 2 * floor(inner_d / rs[2])
    
    # Ensure the inner circle matrix is centered within the outer circle matrix
    inner_circle_padded = matrix(0, nrow = ny, ncol = nx)
    inner_start_x = (nx - nx_inner) %/% 2 + 1
    inner_start_y = (ny - ny_inner) %/% 2 + 1
    inner_circle_padded[inner_start_y:(inner_start_y + ny_inner - 1),
                        inner_start_x:(inner_start_x + nx_inner - 1)] = inner_circle
    
    # Create the donut matrix by subtracting the inner circle from the outer circle
    donut = outer_circle - inner_circle_padded
    donut[donut < 0] = 0
  }
  
  # Normalize the donut matrix
  donut = donut / sum(donut)
  
  if (fillNA) {
    donut[donut <= 0] = NA
  }
  
  return(donut)
}

generate_circle_matrix = function(rs, outer_d) {
  nx = 1 + 2 * floor(outer_d / rs[1])
  ny = 1 + 2 * floor(outer_d / rs[2])
  m = matrix(ncol = nx, nrow = ny)
  m[ceiling(ny/2), ceiling(nx/2)] = 1
  if ((nx != 1) || (ny != 1)) {
    x = terra::rast(m, crs = "+proj=utm +zone=1 +datum=WGS84")
    terra::ext(x) = c(xmin = 0, xmax = nx*rs[1], ymin = 0, ymax = ny*rs[2])
    circle_matrix = as.matrix(terra::distance(x), wide = TRUE) <= outer_d
  }
  return(circle_matrix)
}

