# make_readme_figures.R -- README figures for the BQTF repo (task W-08).
#
# Idea of panels (a) to (c): the area between the estimated tau = 0.1 and tau = 0.9 quantile curves is a band around
# the whole series.  These panels use joint-sampler fits, whose curves never cross, so the lower edge of the band is
# never above its upper edge.  Points are drawn on top of the band and each panel reports the share of points inside it.
# Panel (d) is different: the SPod levels are three SEPARATE fits of the individual sampler, so their order is checked
# before any band is drawn (see spod_panel()).
#
# Panels
#   (a) hero   : VS simulation signal, n = 1,000, Normal errors (E-20 fits; --demo builds stand-in data)
#   (b) growth : Dutch growth data (fdgs), joint k = 2 fits, boys
#   (c) growth : the same, girls
#   (d) spod   : SPod air quality, only with --spod <file>, and in the combined hero only when the order check finds
#                0 crossings (see spod_panel())
#
# Usage (from the repo root):
#   Rscript examples/readme_figures/make_readme_figures.R --demo
#   Rscript examples/readme_figures/make_readme_figures.R --e20 engineering/E20_Showcase/curves.csv
# Flags
#   --demo          hero panel from stand-in data (true signal + Normal quantiles); files and image are labelled DEMO
#   --e20 <path>    E-20 fit file (.csv or .rds); default: engineering/E20_Showcase/curves.csv
#   --bands         also draw the per-curve credible bands as a faint variant (OFF by default)
#   --median        draw the growth tau = 0.5 curve as a thin dark line (ON by default; --no-median turns it off)
#   --spod <path>   also draw the SPod panel from a curve file (.csv; columns in the SPOD COLUMN MAPPING block)
# Outputs: examples/readme_figures/reference_outputs/ (published); --demo writes to examples/readme_figures/out/ instead
#   readme_combined : panels stacked vertically, 3000 px wide at 300 dpi (10 in), 1000 px (3.33 in) per panel, + PDF
#   single panels   : 2400 x 1500 px at 300 dpi (8 x 5 in), + PDF

suppressPackageStartupMessages(library(ggplot2))

# ---- Paths: everything relative to this script's folder ---------------------------------------------------------------
script_dir <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("^--file=", "", a[1]))) else normalizePath(".")
})
repo   <- normalizePath(file.path(script_dir, "..", ".."))
rp     <- function(...) file.path(repo, ...)                          # repo-relative path -> absolute (never printed)
show   <- function(p) sub(paste0("^", repo, "/?"), "", normalizePath(p, mustWork = FALSE))   # print relative only

args <- commandArgs(TRUE)
flag <- function(f) f %in% args
opt  <- function(f, default = NULL) { i <- match(f, args); if (is.na(i) || i == length(args)) default else args[i + 1] }
DEMO       <- flag("--demo")
SHOW_BANDS <- flag("--bands")
SHOW_MED   <- !flag("--no-median")
# Published images go to reference_outputs/; DEMO images go to out/ (never published)
out_dir <- file.path(script_dir, if (DEMO) "out" else "reference_outputs")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- Style (fixed; hex values documented in figures/README.md) --------------------------------------------------------
pal <- list(
  bg       = "#FFFFFF",   # opaque white: reads the same on GitHub light and dark themes
  band     = "#CFE3F6",   # light blue: area between the tau 0.1 and 0.9 curves
  edge     = "#7EA9D8",   # band edges (the two quantile curves), thin
  point    = "#14325C",   # dark blue data points, on top of the band
  truth    = "#111111",   # true noiseless signal, dotted (simulation only)
  median   = "#0A1A33",   # optional growth tau = 0.5 curve
  ci       = "#8FB3DC",   # optional per-curve credible bands (faint)
  text     = "#1F2328",
  subtext  = "#57606A",
  grid     = "#EEF1F4"
)
FONT <- if ("Liberation Sans" %in% systemfonts::system_fonts()$family) "Liberation Sans" else "sans"
PNG_W_IN <- 8; DPI <- 300                                              # single panels: 8 in x 300 dpi = 2400 px

# Two sizes of every panel.  "single" is the stand-alone file; "stack" is one row of the combined hero.  The stack sizes
# are chosen for GitHub, which shows the 3000 px image about 880 px wide (factor 0.293): 1 pt at 300 dpi is then about
# 1.22 px, so a 13 pt base gives titles of 15 pt (~18 px), subtitles and notes of ~11 pt (~13 px) and axis text of
# 11 pt (~13.5 px).  Line widths are scaled by `lw`.
SIZES <- list(single = list(base = 10, lw = 1.0),
              stack  = list(base = 13, lw = 1.35))
STACK_W_IN <- 10; STACK_PANEL_H_IN <- 10 / 3                         # 3000 px wide, 1000 px per panel

theme_bqtf <- function(base = 10) {
  theme_minimal(base_size = base, base_family = FONT) +
    theme(plot.background  = element_rect(fill = pal$bg, colour = NA),
          panel.background = element_rect(fill = pal$bg, colour = NA),
          panel.grid.major = element_line(colour = pal$grid, linewidth = 0.3 * base / 10),
          panel.grid.minor = element_blank(),
          axis.text        = element_text(colour = pal$subtext, size = rel(0.85)),
          axis.title       = element_text(colour = pal$subtext, size = rel(0.9)),
          plot.title       = element_text(colour = pal$text, face = "bold", size = rel(1.15),
                                          margin = margin(b = 0.45 * base)),
          plot.subtitle    = element_text(colour = pal$subtext, size = rel(0.88), margin = margin(b = 0.6 * base)),
          plot.title.position = "plot",
          plot.margin      = margin(10, 16, 8, 12) * base / 10)
}

# ---- Generic band panel: used by every panel --------------------------------------------------------------------------
# pts   : data.frame(x, y)                      data points
# curve : data.frame(x, q10, q90, [q10_lo, q10_hi, q90_lo, q90_hi], [truth], [median])  on a grid
# note  : text for the corner note (e.g. share of points inside the band, computed by the caller at the points' own x)
# band  : FALSE draws no ribbon and no band edges (curve then needs only x and median); used by the SPod fallback
# size  : SIZES$single or SIZES$stack (base font size in pt and line-width factor)
band_panel <- function(pts, curve, note, title, subtitle, xlab, ylab, point_size = 0.55, point_alpha = 0.75,
                       demo = FALSE, band = TRUE, size = SIZES$single) {
  base <- size$base; lw <- size$lw
  p <- ggplot(curve, aes(x = x))
  if (band) p <- p + geom_ribbon(aes(ymin = q10, ymax = q90), fill = pal$band, colour = NA)
  if (band && SHOW_BANDS && all(c("q10_lo", "q10_hi", "q90_lo", "q90_hi") %in% names(curve)))
    p <- p + geom_ribbon(aes(ymin = q10_lo, ymax = q10_hi), fill = pal$ci, alpha = 0.45) +
             geom_ribbon(aes(ymin = q90_lo, ymax = q90_hi), fill = pal$ci, alpha = 0.45)
  if (band) p <- p + geom_line(aes(y = q10), colour = pal$edge, linewidth = 0.35 * lw) +
                     geom_line(aes(y = q90), colour = pal$edge, linewidth = 0.35 * lw)
  p <- p + geom_point(data = pts, aes(x = x, y = y), colour = pal$point, size = point_size, alpha = point_alpha,
                      stroke = 0, shape = 16)
  if ("median" %in% names(curve)) p <- p + geom_line(aes(y = median), colour = pal$median, linewidth = 0.45 * lw)
  if ("truth" %in% names(curve))  p <- p + geom_line(aes(y = truth), colour = pal$bg, linewidth = 1.3 * lw) +
                                           geom_line(aes(y = truth), colour = pal$truth, linewidth = 0.65 * lw,
                                                     linetype = "22")
  p <- p + annotate("label", x = -Inf, y = Inf, label = note, hjust = 0, vjust = 1, family = FONT,
                    size = 0.29 * base, colour = pal$text, fill = alpha(pal$bg, 0.9), border.colour = NA,
                    label.r = unit(0, "pt"), label.padding = unit(0.4 * base, "pt"), lineheight = 1.05) +
    labs(title = title, subtitle = subtitle, x = xlab, y = ylab) + theme_bqtf(base)
  if (demo) p <- p + annotate("text", x = Inf, y = -Inf, label = "DEMO: stand-in curves, not E-20 fits",
                              hjust = 1.02, vjust = -0.8, family = FONT, fontface = "bold", size = 0.32 * base,
                              colour = "#B42318")
  p
}

save_both <- function(p, stem, w_in = PNG_W_IN, h_in = 5) {
  png(file.path(out_dir, paste0(stem, ".png")), width = w_in * DPI, height = h_in * DPI, res = DPI * w_in / PNG_W_IN,
      type = "cairo", bg = pal$bg)
  print(p); invisible(dev.off())
  cairo_pdf(file.path(out_dir, paste0(stem, ".pdf")), width = w_in, height = h_in, family = FONT, bg = pal$bg)
  print(p); invisible(dev.off())
  cat("  wrote", show(file.path(out_dir, paste0(stem, ".{png,pdf}"))), "\n")
}

inside <- function(y, lo, hi) mean(y >= lo & y <= hi)
pct <- function(share) sprintf("%.1f%%", 100 * share)
JOINT_SUB <- "Joint-sampler fit; the curves cannot cross"
# title(): stand-alone panels have no letter; rows of the combined hero start with "(a) ", "(b) ", ...
lettered <- function(letter, text) if (is.null(letter)) text else paste0("(", letter, ") ", text)

# =====================================================================================================================
# (a) HERO: VS simulation, n = 1,000, Normal errors
# =====================================================================================================================
# ---- E-20 COLUMN MAPPING (the ONLY block to edit when Engineering fixes the E-20 schema) ------------------------------
# Left: name used here.  Right: column name in the E-20 file.  Optional entries may be absent from the file.
E20_COLS <- c(
  method = "method",       # sampler that made the fit, e.g. "joint" / "individual"  (required; hero keeps E20_METHOD)
  x      = "x",            # design point or index 1..n                         (required)
  y      = "y",            # observation                                        (required)
  truth  = "truth",        # true noiseless signal (VS baseline)                (required)
  q10    = "q10",          # posterior mean of the tau = 0.1 curve              (required)
  q90    = "q90",          # posterior mean of the tau = 0.9 curve              (required)
  q10_lo = "q10_lo",       # per-curve credible band, tau = 0.1 (optional; drawn only with --bands)
  q10_hi = "q10_hi",
  q90_lo = "q90_lo",       # per-curve credible band, tau = 0.9 (optional)
  q90_hi = "q90_hi"
)
E20_METHOD <- "joint"      # value of the method column used for the hero
E20_REQUIRED <- c("method", "x", "y", "truth", "q10", "q90")
# ---- end of mapping ---------------------------------------------------------------------------------------------------

load_e20 <- function(path) {
  raw <- if (grepl("\\.rds$", path, ignore.case = TRUE)) readRDS(path) else read.csv(path, check.names = FALSE)
  raw <- as.data.frame(raw, check.names = FALSE)
  miss <- E20_COLS[E20_REQUIRED][!E20_COLS[E20_REQUIRED] %in% names(raw)]
  if (length(miss)) stop("E-20 file ", show(path), " lacks required column(s): ", paste(miss, collapse = ", "),
                         "\n  columns found: ", paste(names(raw), collapse = ", "),
                         "\n  edit the E20_COLS block in make_readme_figures.R")
  keep <- E20_COLS[E20_COLS %in% names(raw)]
  d <- setNames(raw[keep], names(keep))
  d <- d[d$method == E20_METHOD, , drop = FALSE]
  if (!nrow(d)) stop("E-20 file ", show(path), " has no rows with method == \"", E20_METHOD, "\"")
  d[order(d$x), , drop = FALSE]
}

# Stand-in data: the repo's own VS generator (simulate_data() in method/joint/Joint_Sampler_PMALA_Augmented.R) makes y;
# the curves are the true conditional quantiles baseline + qnorm(tau) * (1 + xs^2) / 4 of that generator.
demo_e20 <- function(seed = 1L, n = 1000L) {
  src <- rp("method", "joint", "Joint_Sampler_PMALA_Augmented.R")
  ex <- parse(src)
  def <- Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) &&
                  identical(e[[2]], as.name("simulate_data")), as.list(ex))
  if (!length(def)) stop("simulate_data() not found in ", show(src))
  env <- new.env(); eval(def[[1]], env)
  dat <- env$simulate_data(seed, n, c(0.1, 0.9), "VS", "Normal")
  w <- 0.03                                                      # fake half-width, only for the --bands variant
  data.frame(method = "joint", x = dat$x, y = dat$y, truth = dat$baseline, q10 = dat$truth[, 1], q90 = dat$truth[, 2],
             q10_lo = dat$truth[, 1] - w, q10_hi = dat$truth[, 1] + w,
             q90_lo = dat$truth[, 2] - w, q90_hi = dat$truth[, 2] + w)
}

# Returns list(make = function(size, letter), tag, share), or NULL when there is no E-20 file.
hero_panel <- function() {
  if (DEMO) {
    d <- demo_e20(); tag <- "_DEMO"
    cat("hero: DEMO stand-in data (VS generator, seed 1, n = 1000, Normal errors)\n")
  } else {
    path <- opt("--e20")
    if (is.null(path)) {
      path <- rp("engineering", "E20_Showcase", "curves.csv")
      if (!file.exists(path)) { cat("hero: no engineering/E20_Showcase/curves.csv yet; skipped (use --demo)\n"); return(NULL) }
    } else if (!grepl("^/", path)) path <- rp(path)
    d <- load_e20(path); tag <- ""
    cat("hero: E-20 file", show(path), "\n")
  }
  share <- inside(d$y, d$q10, d$q90)
  cat(sprintf("hero: n = %d, share inside [q0.1, q0.9] = %.4f\n", nrow(d), share))
  note <- sprintf("Band: \u03c4 = 0.1 to 0.9 curves\n%s of points inside (nominal 80%%)\nDotted line: the true function f",
                  pct(share))
  make <- function(size = SIZES$single, letter = NULL) {
    stack <- identical(size, SIZES$stack)
    band_panel(pts = d[c("x", "y")], curve = d, note = note,
               title = lettered(letter, sprintf("Simulated data from an explicit function, n = %s", format(nrow(d), big.mark = ","))),
               subtitle = JOINT_SUB, xlab = "Index", ylab = "y",
               point_size = if (stack) 1.25 else 1.0, point_alpha = 0.85, demo = DEMO, size = size)
  }
  list(make = make, tag = tag, share = share)
}

# =====================================================================================================================
# (b), (c) GROWTH: fdgs heights, joint k = 2 fits
# =====================================================================================================================
growth_panel <- function(sex) {
  kids <- read.csv(rp("applications", "Growth", "data", "fdgs.csv"))
  kids <- kids[kids$sex == sex & !is.na(kids$hgt), c("age", "hgt")]
  fit  <- read.csv(rp("applications", "Growth", "results_joint_k2", sex, "posterior_summary.csv"))
  at <- function(t, col = "estimate") { f <- fit[fit$tau == t, ]; f <- f[order(f$age), ]; setNames(f[[col]], f$age) }
  ages <- sort(unique(fit$age))
  curve <- data.frame(x = ages, q10 = at(0.1), q90 = at(0.9), q10_lo = at(0.1, "lower"), q10_hi = at(0.1, "upper"),
                      q90_lo = at(0.9, "lower"), q90_hi = at(0.9, "upper"))
  if (SHOW_MED) curve$median <- at(0.5)
  # each child's band: linear interpolation of the curves at the child's age (ends held constant outside the grid)
  lo <- approx(ages, curve$q10, xout = kids$age, rule = 2)$y
  hi <- approx(ages, curve$q90, xout = kids$age, rule = 2)$y
  share <- inside(kids$hgt, lo, hi)
  cat(sprintf("growth %-4s: children = %d, share inside [q0.1, q0.9] = %.4f (below q0.1 %.4f, above q0.9 %.4f)\n",
              sex, nrow(kids), share, mean(kids$hgt < lo), mean(kids$hgt > hi)))
  lab <- c(boy = "boys", girl = "girls")[[sex]]
  note <- sprintf("Band: \u03c4 = 0.1 to 0.9 curves%s\n%s of children inside (nominal 80%%)",
                  if (SHOW_MED) "; line: median" else "", pct(share))
  make <- function(size = SIZES$single, letter = NULL) {
    stack <- identical(size, SIZES$stack)
    band_panel(pts = data.frame(x = kids$age, y = kids$hgt), curve = curve, note = note,
               title = lettered(letter, sprintf("Height of %s Dutch %s, by age", format(nrow(kids), big.mark = ","),
                                                if (is.null(letter)) lab else "children")),   # hero: no sex named (owner 11-26)
               subtitle = JOINT_SUB, xlab = "Age (years)", ylab = "Height (cm)",
               point_size = if (stack) 0.8 else 0.6, point_alpha = if (stack) 0.3 else 0.5, size = size) +
      scale_x_continuous(breaks = seq(0, 22, 2))
  }
  list(make = make, share = share, n = nrow(kids))
}

# =====================================================================================================================
# (d) SPOD air quality (curves come after the E-18 refit; drawn only with --spod <file>)
# =====================================================================================================================
# The SPod fits only have tau = 0.01, 0.05 and 0.10 (no upper quantiles), so the SPod story is a LOW baseline band
# sitting beneath the data, with the pollution plumes clearly above it.  The note reports the share of readings BELOW
# the tau_hi curve (nominal = tau_hi), not a share inside.
#
# The three levels are SEPARATE fits of the individual sampler (paper/sections/data_application.tex), so nothing
# guarantees their order.  spod_panel() therefore checks all three curves at every time point and counts the crossings:
# a time point is a crossing when lower > middle or middle > upper.  The count is printed in the stand-alone panel note
# and on the console.
#   0 crossings  : band between the tau_lo and tau_hi curves, the tau_mid curve as the line; the panel is also added to
#                  the combined hero as row (d)
#   >= 1 crossing: NO band; only the tau_mid curve is drawn (median-only fallback) in the stand-alone figure, and the
#                  combined hero keeps its three joint panels
# The panel never says "joint" or "cannot cross".
#
# spod_panel(time, y, lower, upper, middle, tau_lo = 0.01, tau_hi = 0.10, tau_mid = 0.05, time_lab = "Time",
#            size = SIZES$single, letter = NULL)
#   time    : numeric or POSIXct, length n (one reading per point)
#   y       : SPod reading, length n
#   lower, middle, upper : fitted curves at tau_lo, tau_mid, tau_hi, evaluated at `time` (length n each, no NA)
#   size, letter : SIZES$stack and a letter for the combined hero (shorter note: share and band legend only)
# Returns list(plot, share_below, n_cross, n, band_drawn).
spod_crossings <- function(lower, middle, upper) sum(lower > middle | middle > upper)

spod_panel <- function(time, y, lower, upper, middle, tau_lo = 0.01, tau_hi = 0.10, tau_mid = 0.05,
                       time_lab = "Time", size = SIZES$single, letter = NULL) {
  n <- length(y)
  stopifnot(length(time) == n, length(lower) == n, length(middle) == n, length(upper) == n,
            !anyNA(lower), !anyNA(middle), !anyNA(upper))
  stack <- identical(size, SIZES$stack)
  n_cross <- spod_crossings(lower, middle, upper)
  band_ok <- n_cross == 0
  o <- order(time); x <- as.numeric(time)[o]
  curve <- data.frame(x = x, median = middle[o])
  if (band_ok) { curve$q10 <- lower[o]; curve$q90 <- upper[o] }   # band_panel's q10/q90 = generic lower/upper edges
  share_below <- mean(y < upper)
  legend_line <- if (band_ok) sprintf("Band: \u03c4 = %.2f to %.2f curves; line: \u03c4 = %.2f", tau_lo, tau_hi, tau_mid)
                 else sprintf("Line: \u03c4 = %.2f curve only", tau_mid)
  share_line <- sprintf("%s of readings below the \u03c4 = %.2f curve (nominal %.0f%%)", pct(share_below), tau_hi,
                        100 * tau_hi)
  check_line <- if (band_ok) sprintf("Order check: 0 of %s time points with crossed curves", format(n, big.mark = ","))
                else sprintf("Order check: curves cross at %s of %s time points; band not drawn",
                             format(n_cross, big.mark = ","), format(n, big.mark = ","))
  note <- if (stack) paste(legend_line, share_line, sep = "\n") else paste(share_line, check_line, sep = "\n")
  p <- band_panel(pts = data.frame(x = x, y = y[o]), curve = curve, note = note,
                  title = lettered(letter, "Air quality: SPod sensor readings and their low baseline"),
                  subtitle = if (stack) "Each level fitted separately (individual sampler)"
                             else paste0("Each level fitted separately (individual sampler). ",
                                         if (band_ok) paste0("Band: \u03c4 = ", tau_lo, " to ", tau_hi,
                                                             "; line: \u03c4 = ", tau_mid)
                                         else paste0("Line: \u03c4 = ", tau_mid, " only")),
                  xlab = time_lab, ylab = "Reading", point_size = if (stack) 0.55 else 0.7,
                  point_alpha = if (stack) 0.55 else 0.7, band = band_ok, size = size)
  list(plot = p, share_below = share_below, n_cross = n_cross, n = n, band_drawn = band_ok)
}

# ---- SPOD COLUMN MAPPING (the ONLY block to edit when Engineering fixes the E-18 curve file) --------------------------
# Left: name used here.  Right: column name in engineering's spod_curves.csv (8,640 rows, one per 10-s reading).
SPOD_COLS <- c(
  time   = "time",         # clock label of the reading                          (required)
  y      = "y",            # SPod reading                                        (required)
  q01    = "q01",          # pointwise posterior median, tau = 0.01              (required)
  q05    = "q05",          # pointwise posterior median, tau = 0.05              (required)
  q10    = "q10",          # pointwise posterior median, tau = 0.10              (required)
  q01_lo = "q01_lo", q01_hi = "q01_hi",   # per-curve credible limits (optional; read but not drawn)
  q05_lo = "q05_lo", q05_hi = "q05_hi",
  q10_lo = "q10_lo", q10_hi = "q10_hi"
)
SPOD_REQUIRED <- c("time", "y", "q01", "q05", "q10")
# ---- end of mapping ---------------------------------------------------------------------------------------------------

# Returns list(make = function(size, letter), n_cross, band_drawn, share_below, n), or NULL (with a console message)
# when a required column is missing, e.g. a tau level on HOLD.
spod_from_file <- function(path) {
  raw <- read.csv(path, check.names = FALSE)
  miss <- SPOD_COLS[SPOD_REQUIRED][!SPOD_COLS[SPOD_REQUIRED] %in% names(raw)]
  if (length(miss)) {
    cat("spod: file ", show(path), " lacks required column(s) ", paste(miss, collapse = ", "),
        " (a tau level on HOLD?); SPod panel SKIPPED\n  columns found: ", paste(names(raw), collapse = ", "),
        "\n  if the names changed, edit the SPOD_COLS block in make_readme_figures.R\n", sep = "")
    return(NULL)
  }
  keep <- SPOD_COLS[SPOD_COLS %in% names(raw)]
  d <- setNames(raw[keep], names(keep))
  tm <- d$time; lab <- "Time"
  if (!is.numeric(tm)) {                                  # clock labels: parse, else fall back to the reading index
    tm <- tryCatch(as.POSIXct(tm, tz = "UTC"), error = function(e) NULL)
    if (is.null(tm) || anyNA(tm)) { tm <- seq_len(nrow(d)); lab <- "Reading index" }
  }
  if (inherits(tm, "POSIXct")) lab <- "Time of day (UTC)"
  clock_axis <- function(p) {
    if (!inherits(tm, "POSIXct")) return(p)
    p + scale_x_continuous(                                 # ticks every 6 hours of the clock labels
      breaks = function(lim) {                              # empty when the span holds no 6-hour tick
        b0 <- ceiling(lim[1] / 21600) * 21600
        if (!is.finite(b0) || b0 > lim[2]) return(numeric(0))
        seq(b0, lim[2], by = 21600)
      },
      labels = function(v) format(as.POSIXct(v, origin = "1970-01-01", tz = "UTC"), "%H:%M"))
  }
  make <- function(size = SIZES$single, letter = NULL) {
    sp <- spod_panel(tm, d$y, d$q01, d$q10, d$q05, time_lab = lab, size = size, letter = letter)
    clock_axis(sp$plot)
  }
  sp <- spod_panel(tm, d$y, d$q01, d$q10, d$q05, time_lab = lab)
  cat(sprintf("spod: file %s, n = %d, order check: %d crossing(s) (q01 > q05 or q05 > q10), %s; share below q10 = %.4f\n",
              show(path), sp$n, sp$n_cross, if (sp$band_drawn) "band drawn" else "FALLBACK: tau = 0.05 curve only, no band",
              sp$share_below))
  list(make = make, n_cross = sp$n_cross, band_drawn = sp$band_drawn, share_below = sp$share_below, n = sp$n)
}

# =====================================================================================================================
# Combined hero: full-width panels stacked vertically, plot areas aligned (ggplot2 + grid only, no extra packages)
# =====================================================================================================================
combine <- function(plots, stem) {
  h_in <- STACK_PANEL_H_IN * length(plots)
  draw <- function() {                       # grobs are built here, on the open device, so text widths use its fonts
    gs <- lapply(plots, ggplotGrob)
    w  <- do.call(grid::unit.pmax, lapply(gs, function(g) g$widths))    # same left edge for every plot area
    for (i in seq_along(gs)) gs[[i]]$widths <- w
    grid::grid.newpage()
    grid::grid.rect(gp = grid::gpar(fill = pal$bg, col = NA))
    grid::pushViewport(grid::viewport(layout = grid::grid.layout(length(gs), 1)))
    for (i in seq_along(gs)) {
      grid::pushViewport(grid::viewport(layout.pos.row = i, layout.pos.col = 1))
      grid::grid.draw(gs[[i]]); grid::popViewport()
    }
  }
  png(file.path(out_dir, paste0(stem, ".png")), width = round(STACK_W_IN * DPI), height = round(h_in * DPI), res = DPI,
      type = "cairo", bg = pal$bg); draw(); invisible(dev.off())
  cairo_pdf(file.path(out_dir, paste0(stem, ".pdf")), width = STACK_W_IN, height = h_in, family = FONT, bg = pal$bg)
  draw(); invisible(dev.off())
  cat(sprintf("  wrote %s (%d panels, PNG %d x %d px)\n", show(file.path(out_dir, paste0(stem, ".{png,pdf}"))),
              length(plots), round(STACK_W_IN * DPI), round(h_in * DPI)))
}

# =====================================================================================================================
# Build
# =====================================================================================================================
cat("output folder:", show(out_dir), "| font:", FONT, "| per-curve bands:", SHOW_BANDS, "\n")
sfx <- if (SHOW_BANDS) "_bands" else ""

hero <- hero_panel()
gb <- growth_panel("boy")
gg <- growth_panel("girl")

if (!is.null(hero)) save_both(hero$make(), paste0("readme_hero_vs", hero$tag, sfx))
save_both(gb$make(), paste0("readme_growth_boys", sfx))
save_both(gg$make(), paste0("readme_growth_girls", sfx))

spod <- NULL
spod_path <- opt("--spod")
if (!is.null(spod_path)) {
  if (!grepl("^/", spod_path)) spod_path <- rp(spod_path)
  spod <- spod_from_file(spod_path)
  if (!is.null(spod)) save_both(spod$make(), "readme_spod")
}

if (!is.null(hero)) {
  S <- SIZES$stack
  rows <- list(gb$make(S, "a"), hero$make(S, "b"))   # owner 11-26: growth (boys, titled "children") then the simulation; no girls panel
  # Owner 11-26: the hero is these two panels only; the SPod panel is written as its own file (readme_spod) and is
  # never added to the hero.
  combine(rows, paste0("readme_combined", hero$tag, sfx))
} else {
  # No E-20 curves yet: the combined hero is the two growth panels, lettered (a) and (b)
  cat("combined: no E-20 curves -> growth panels only\n")
  S <- SIZES$stack
  combine(list(gb$make(S, "a"), gg$make(S, "b")), paste0("readme_combined", sfx))
}

cat(sprintf("SUMMARY share_inside: hero %s | growth boys %.4f | growth girls %.4f%s\n",
            if (is.null(hero)) "NA" else sprintf("%.4f", hero$share), gb$share, gg$share,
            if (is.null(spod)) "" else sprintf(" | spod share_below_q10 %.4f, crossings %d", spod$share_below,
                                               spod$n_cross)))
