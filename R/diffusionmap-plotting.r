#' @include diffusionmap.r
#' @include plothelpers.r
NULL

#' 3D or 2D plot of diffusion map
#' 
#' If you want to plot the eigenvalues, simply \code{plot(eigenvalues(dm)[start:end], ...)}
#' 
#' If you specify negative numbers as diffusion components (e.g. \code{plot(dm, c(-1,2))}), then the corresponding components will be flipped.
#' 
#' @param x            A \link{DiffusionMap}
#' @param dims,y       Diffusion components (eigenvectors) to plot (default: first three components; 1:3)
#' @param new_dcs      An optional matrix also containing the rows specified with \code{y} and plotted. (default: no more points)
#' @param new_data     A data set in the same format as \code{x} that is used to create \code{new_dcs <- \link{dm_predict}(dif, new_data)}
#' @param col          Single color string or vector of discrete or categoric values to be mapped to colors.
#'                     E.g. a column of the data matrix used for creation of the diffusion map. (default: \link{par}\code{('fg')})
#' @param col_by       Specify a \code{dataset(x)} or \code{phenoData(dataset(x))} column to use as color
#' @param col_limits   If \code{col} is a continuous (=double) vector, this can be overridden to map the color range differently than from min to max (e.g. specify \code{c(0, 1)})
#' @param col_new      If \code{new_dcs} is given, it will take on this color. A vector is also possible. (default: red)
#' @param pal          Palette used to map the \code{col} vector to colors. (default: use \code{\link{cube_helix}} for continuous and \code{\link{palette}()} for discrete data)
#' @param pal_new      Palette used to map the \code{col_new} vector to colors. (default: see \code{pal} argument)
#' @param ...          Parameters passed to \link{plot}, \link[scatterplot3d]{scatterplot3d}, or \link[rgl]{plot3d} (if \code{interactive == TRUE})
#' @param mar          Bottom, left, top, and right margins (default: \code{par(mar)})
#' @param ticks        logical. If TRUE, show axis ticks (default: FALSE)
#' @param axes         logical. If TRUE, draw plot axes (default: Only if \code{ticks} is TRUE)
#' @param box          logical. If TRUE, draw plot frame (default: TRUE or the same as \code{axes} if specified)
#' @param legend_main  Title of legend. (default: nothing unless \code{col_by} is given)
#' @param legend_opts  Other \link{colorlegend} options (default: empty list)
#' @param interactive  Use \link[rgl]{plot3d} to plot instead of \link[scatterplot3d]{scatterplot3d}?
#' @param draw_legend  logical. If TRUE, draw color legend (default: TRUE if \code{col_by} is given or \code{col} is given and a vector to be mapped)
#' @param consec_col   If \code{col} or \code{col_by} refers to an integer column, with gaps (e.g. \code{c(5,0,0,3)}) use the palette color consecutively (e.g. \code{c(3,1,1,2)})
#' @param col_na       Color for \code{NA} in the data. specify \code{NA} to hide.
#' @param plot_more    Function that will be called while the plot margins are temporarily changed
#'                     (its \code{p} argument is the rgl or scatterplot3d instance or NULL,
#'                     its \code{rescale} argument is \code{NULL} or of the shape \code{list(from = c(a, b), to = c(c,d))})
#' 
#' @return The return value of the underlying call is returned, i.e. a scatterplot3d or rgl object.
#' 
#' @examples
#' data(guo)
#' plot(DiffusionMap(guo))
#' 
#' @aliases plot.DiffusionMap plot,DiffusionMap,missing-method plot,DiffusionMap,numeric-method
#' 
#' @importFrom graphics par axis plot plot.new
#' @importFrom grDevices palette
#' @importFrom scatterplot3d scatterplot3d
#' 
#' @name plot.DiffusionMap
#' @export
plot.DiffusionMap <- function(
	x, dims = 1:3,
	new_dcs = NULL, new_data = NULL,
	col = NULL, col_by = NULL, col_limits = NULL,
	col_new = 'red',
	pal = NULL, pal_new = NULL,
	...,
	mar = NULL,
	ticks = FALSE,
	axes = TRUE,
	box = FALSE,
	legend_main = col_by, legend_opts = list(),
	interactive = FALSE,
	draw_legend = !is.null(col_by) || (length(col) > 1 && !is.character(col)),
	consec_col = TRUE, col_na = 'grey',
	plot_more = function(p, ..., rescale = NULL) NULL
) {
	dif <- x
	
	if (interactive) {
		if (!requireNamespace('rgl', quietly = TRUE))
			stop(sprintf('The package %s is required for interactive plots', sQuote('rgl')))
		if (length(dims) != 3L)
			stop('Only 3d plots can be made interactive')
	}
	
	if (!is.null(new_data)) {
		if (!is.null(new_dcs)) stop('either provide new_data or new_dcs')
		new_dcs <- dm_predict(dif, new_data)
	}
	
	if (!is.null(col) && !is.null(col_by)) stop('Only specify one of col or col_by')
	
	col_default <- is.null(col) && is.null(col_by)
	if (col_default) col <- par('col')
	
	#get col from data
	if (!is.null(col_by)) {
		col <- extract_col(dataset(dif), col_by)
		if (is.null(col)) stop('no "', col_by, '" in dataset(x)')
	}
	
	# extend margin for legend
	mar_old <- par('mar')
	if (is.null(mar)) {
		mar <- mar_old
		if (draw_legend) {
			mar[[4]] <- mar[[4]] + 5
		}
	}
	par(mar = mar)
	
	# reduce axis label position if it is the default and no tick marks are given
	if (all(par('mgp') == c(3, 1, 0)) && !ticks) {
		on.exit(par(mgp = c(3, 1, 0)))
		par(mgp = c(1, 0, 0))
	}
	
	# make consecutive the colors for the color legend
	if (is.integer(col) && consec_col) {
		# c(5,0,0,3) -> c(3,1,1,2)
		col <- factor(col)
	}
	
	# use a fitting default palette
	if (is.null(pal)) {
		col_column <- if (is.null(col)) dif[[col_by]] else col
		pal <- if (is.double(col_column)) cube_helix else palette()
	}
	
	# colors to assign to plot rows
	col_plot <- col
	if (is.double(col))
		col_plot <- continuous_colors(col, pal, col_limits)
	else if (is.factor(col_plot))
		col_plot <- as.integer(col_plot)
	
	# limit pal to number of existing colors to maybe attach col_new
	length_pal <-
		if (is.factor(col))
			length(levels(col))
		else if (is.integer(col))
			length(unique(col_plot))
		else 5L
	if (is.function(pal)) {
		# pal is a colorRampPalette-type function
		pal <- pal(length_pal)
	} else {
		# pal is a vector
		length_pal <- min(length(pal), length_pal)
		pal <- pal[seq_len(length_pal)]
	}
	
	# set col_plot to color strings
	if (is.integer(col_plot)) {
		idx_wrapped <- ((col_plot - 1L) %% length_pal) + 1L
		col_plot <- pal[idx_wrapped]
		col_plot[is.na(col_plot)] <- col_na
	}
	
	# attach the new_dcs and col_new parameters to data and colors
	point_data <- flipped_dcs(dif, dims)
	if (!is.null(new_dcs)) {
		point_data <- rbind(point_data, flipped_dcs(new_dcs, dims))
		if (length(col_new) > 1L) {
			if (length(col_new) != nrow(new_dcs)) stop('either provide one col_new or ', nrow(new_dcs), ', not ', length(col_new))
			if (is.null(pal_new))
				pal_new <- if (is.double(col_new)) cube_helix else palette()
			if (is.double(col_new))
				col_new <- continuous_colors(col_new, pal_new)
			
			col_plot <- c(rep_len(col_plot, nrow(point_data) - nrow(new_dcs)),
										col_new)
		} else {
			if (!is.character(col_new)) {
				idx_wrapped <- ((col_plot - 1L) %% length_pal) + 1L
				col_new <- pal[idx_wrapped]
			}
			col_plot <- c(rep_len(col_plot, nrow(point_data) - nrow(new_dcs)),
										rep_len(col_new, nrow(new_dcs)))
			#colorlegend
			if (!is.double(col)) {
				col <- factor(c(as.character(col), 'proj'))
			}
			pal <- c(pal, col_new)
		}
	}
	
	if (length(dims) == 2) {
		p <- NULL
		
		plot(point_data, ..., col = col_plot, axes = FALSE, frame.plot = box)
		if (ticks) {
			r1 <- NULL
			r2 <- NULL
			tl <- 1
		} else {
			r1 <- range(point_data[, 1L])
			r2 <- range(point_data[, 2L])
			tl <- 0
		}
		plot_more(p, rescale = NULL)
		al <- if (axes && !box) 1 else 0
		axis(1, r1, labels = ticks, lwd = al, lwd.ticks = tl)
		axis(2, r2, labels = ticks, lwd = al, lwd.ticks = tl)
	} else if (length(dims) == 3L) {
		if (interactive) {
			p <- rgl::plot3d(point_data, ..., col = col_plot, axes = FALSE, box = FALSE)
			if (axes || ticks) {
				axtype = if (axes) 'lines' else 'cull'
				nticks = if (ticks) 5 else 0
				rgl::bbox3d(xlen = nticks, ylen = nticks, zlen = nticks, front = axtype, back = axtype)
			}
			if (box) rgl::box3d()
			plot_more(p, rescale = NULL)
		} else {
			rescale <- NULL
			if (!ticks) {  # -> scatterplot3d's pretty() should not mess things up
				rescale <- list(from = range(point_data, na.rm = TRUE, finite = TRUE), to = c(0,1))
				point_data <- rescale_mat(point_data, from = rescale$from, to = rescale$to)
			}
			p <- scatterplot3d(
				point_data, ..., color = col_plot, mar = mar,
				axis = axes || box || ticks, lty.axis = if (axes || box) 'solid' else 'blank',
				box = box, tick.marks = ticks)
			plot_more(p, rescale = rescale)
		}
	} else stop(sprintf('dims is of wrong length (%s): Can only handle 2 or 3 dimensions', dims))
	
	if (draw_legend) {
		col_legend <- if (is.double(col) && !is.null(col_limits)) col_limits else col
		args <- c(list(col_legend, pal = pal, main = legend_main), legend_opts)
		if (interactive) {
			rgl::bgplot3d({
				plot.new()
				do.call(colorlegend, args)
			})
		} else {
			do.call(colorlegend, args)
		}
	}
	
	par(mar = mar_old)
	invisible(p)
}

#' @importFrom Biobase varLabels exprs
extract_col <- function(annot_data, col_by) tryCatch({
	if (inherits(annot_data, 'ExpressionSet')) {
		if (col_by %in% varLabels(annot_data))
			annot_data[[col_by]]
		else
			exprs(annot_data)[col_by, ]
	} else {
		annot_data[, col_by]
	}
}, error = function(e) stop(sprintf('Invalid `col_by`: No column, annotation, or feature found with name %s', dQuote(col_by))))

# test:
# layout(matrix(1:8, 2))
# mapply(function(t, a, b) plot(dif, ticks = t, axes = a, box = b, main = sprintf('t=%s a=%s b=%s', t, a, b)),
#        c(T,T,T,T,F,F,F,F), c(T,F,T,F,T,F,T,F), c(T,T,F,F,T,T,F,F))

#' @name plot.DiffusionMap
#' @export
setMethod('plot', c(x = 'DiffusionMap', y = 'numeric'), function(x, y, ...) plot.DiffusionMap(x, y, ...))

#' @name plot.DiffusionMap
#' @export
setMethod('plot', c(x = 'DiffusionMap', y = 'missing'), function(x, y, ...) plot(x, seq_len(min(3L, ncol(eigenvectors(x)))), ...))
