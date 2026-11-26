# make_readme_figures.R -- README figures for the BQTF repo (W-08, item C of writing/W08_Repo/BRIEF.md).
#
# Idea of every panel: the area between the estimated tau = 0.1 and tau = 0.9 quantile curves is a band around the
# whole series ("the series has its own 80% interval").  The joint sampler's curves never cross, so the band is always
# a valid region.  Points are drawn on top of the band and each panel reports the share of points inside it.
#
# Panels
#   (1) hero   : VS simulation signal, n = 1,000, Normal errors (E-20 fits; --demo builds stand-in data)
#   (2) growth : Dutch growth data (fdgs), joint k = 2 fits, boys (girls and both-sex panels are also written)
#   (3) spod   : SPod air-quality hook, a stub until the E-18 refit (see spod_panel() below)
#
# Usage (from the repo root, through the cluster wrapper):
#   owls_run -j 1 -- Rscript writing/W08_Repo/figures/make_readme_figures.R --demo
#   owls_run -j 1 -- Rscript writing/W08_Repo/figures/make_readme_figures.R --e20 engineering/E20_Showcase/<file>.csv
# Flags
#   --demo          hero panel from stand-in data (true signal + Normal quantiles); files and image are labelled DEMO
#   --e20 <path>    E-20 fit file (.csv or .rds); default: the first .csv/.rds in engineering/E20_Showcase/
#   --bands         also draw the per-curve credible bands as a faint variant (OFF by default)
#   --median        draw the growth tau = 0.5 curve as a thin dark line (ON by default; --no-median turns it off)
# Outputs: writing/W08_Repo/figures/out/  (PNG 2400 px wide at 300 dpi, and PDF)

suppressPackageStartupMessages(library(ggplot2))

# ---- Paths: everything relative to this script's folder ---------------------------------------------------------------
script_dir <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("^--file=", "", a[1]))) else normalizePath(".")
})
repo   <- normalizePath(file.path(script_dir, "..", "..", ".."))
rp     <- function(...) file.path(repo, ...)                          # repo-relative path -> absolute (never printed)
show   <- function(p) sub(paste0("^", repo, "/?"), "", normalizePath(p, mustWork = FALSE))   # print relative only
out_dir <- file.path(script_dir, "out")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

args <- commandArgs(TRUE)
flag <- function(f) f %in% args
opt  <- function(f, default = NULL) { i <- match(f, args); if (is.na(i) || i == length(args)) default else args[i + 1] }
DEMO       <- flag("--demo")
SHOW_BANDS <- flag("--bands")
SHOW_MED   <- !flag("--no-median")

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
PNG_W_IN <- 8; DPI <- 300                                              # 8 in x 300 dpi = 2400 px

theme_bqtf <- function(base = 10) {
  theme_minimal(base_size = base, base_family = FONT) +
    theme(plot.background  = element_rect(fill = pal$bg, colour = NA),
          panel.background = element_rect(fill = pal$bg, colour = NA),
          panel.grid.major = element_line(colour = pal$grid, linewidth = 0.3),
          panel.grid.minor = element_blank(),
          axis.text        = element_text(colour = pal$subtext, size = rel(0.85)),
          axis.title       = element_text(colour = pal$subtext, size = rel(0.9)),
          plot.title       = element_text(colour = pal$text, face = "bold", size = rel(1.15), margin = margin(b = 2)),
          plot.subtitle    = element_text(colour = pal$subtext, size = rel(0.88), margin = margin(b = 6)),
          plot.title.position = "plot",
          plot.margin      = margin(10, 14, 8, 10))
}

# ---- Generic band panel: used by all three panels ---------------------------------------------------------------------
# pts   : data.frame(x, y)                      data points
# curve : data.frame(x, q10, q90, [q10_lo, q10_hi, q90_lo, q90_hi], [truth], [median])  on a grid
# note  : text for the corner note (e.g. share of points inside the band, computed by the caller at the points' own x)
band_panel <- function(pts, curve, note, title, subtitle, xlab, ylab, point_size = 0.55, point_alpha = 0.75,
                       truth_lab = NULL, demo = FALSE) {
  p <- ggplot(curve, aes(x = x)) +
    geom_ribbon(aes(ymin = q10, ymax = q90), fill = pal$band, colour = NA)
  if (SHOW_BANDS && all(c("q10_lo", "q10_hi", "q90_lo", "q90_hi") %in% names(curve)))
    p <- p + geom_ribbon(aes(ymin = q10_lo, ymax = q10_hi), fill = pal$ci, alpha = 0.45) +
             geom_ribbon(aes(ymin = q90_lo, ymax = q90_hi), fill = pal$ci, alpha = 0.45)
  p <- p + geom_line(aes(y = q10), colour = pal$edge, linewidth = 0.35) +
           geom_line(aes(y = q90), colour = pal$edge, linewidth = 0.35) +
           geom_point(data = pts, aes(x = x, y = y), colour = pal$point, size = point_size, alpha = point_alpha,
                      stroke = 0, shape = 16)
  if ("median" %in% names(curve)) p <- p + geom_line(aes(y = median), colour = pal$median, linewidth = 0.45)
  if ("truth" %in% names(curve))  p <- p + geom_line(aes(y = truth), colour = pal$bg, linewidth = 1.3) +
                                           geom_line(aes(y = truth), colour = pal$truth, linewidth = 0.65,
                                                     linetype = "22")
  if (!is.null(truth_lab)) note <- paste0(note, "\n", truth_lab)
  p <- p + annotate("label", x = -Inf, y = Inf, label = note, hjust = 0, vjust = 1, family = FONT, size = 2.9,
                    colour = pal$text, fill = alpha(pal$bg, 0.9), border.colour = NA, label.r = unit(0, "pt"),
                    label.padding = unit(4, "pt"), lineheight = 1.05) +
    labs(title = title, subtitle = subtitle, x = xlab, y = ylab) + theme_bqtf()
  if (demo) p <- p + annotate("text", x = Inf, y = -Inf, label = "DEMO: stand-in curves, not E-20 fits",
                              hjust = 1.02, vjust = -0.8, family = FONT, fontface = "bold", size = 3.2,
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
note_inside <- function(share) sprintf("%.1f%% of points inside the band (nominal 80%%)", 100 * share)

# =====================================================================================================================
# (1) HERO: VS simulation, n = 1,000, Normal errors
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

hero_panel <- function() {
  if (DEMO) {
    d <- demo_e20(); tag <- "_DEMO"
    cat("hero: DEMO stand-in data (VS generator, seed 1, n = 1000, Normal errors)\n")
  } else {
    path <- opt("--e20")
    if (is.null(path)) {
      cand <- list.files(rp("engineering", "E20_Showcase"), pattern = "\\.(csv|rds)$", full.names = TRUE,
                         ignore.case = TRUE)
      if (!length(cand)) { cat("hero: no E-20 file in engineering/E20_Showcase/; skipped (use --demo)\n"); return(NULL) }
      path <- cand[1]
    } else if (!grepl("^/", path)) path <- rp(path)
    d <- load_e20(path); tag <- ""
    cat("hero: E-20 file", show(path), "\n")
  }
  share <- inside(d$y, d$q10, d$q90)
  cat(sprintf("hero: n = %d, share inside [q0.1, q0.9] = %.4f\n", nrow(d), share))
  p <- band_panel(pts = d[c("x", "y")], curve = d, note = note_inside(share),
                  title = "Simulation: VS signal, n = 1,000",
                  subtitle = "Band between the joint-sampler \u03c4 = 0.1 and 0.9 curves; dotted: true signal",
                  xlab = "Index", ylab = "y", point_size = 1.0, point_alpha = 0.85, demo = DEMO)
  list(plot = p, tag = tag, share = share)
}

# =====================================================================================================================
# (2) GROWTH: fdgs heights, joint k = 2 fits
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
  p <- band_panel(pts = data.frame(x = kids$age, y = kids$hgt), curve = curve, note = note_inside(share),
                  title = sprintf("Growth: height of %s Dutch %s", format(nrow(kids), big.mark = ","), lab),
                  subtitle = "Joint-sampler fit; the curves cannot cross. Band: \u03c4 = 0.1 to 0.9; line: median",
                  xlab = "Age (years)", ylab = "Height (cm)", point_size = 0.6, point_alpha = 0.5) +
    scale_x_continuous(breaks = seq(0, 22, 4))
  list(plot = p, share = share, n = nrow(kids))
}

# =====================================================================================================================
# (3) SPOD air quality: HOOK ONLY (curves come after the E-18 refit)
# =====================================================================================================================
# The SPod fits only have tau = 0.01, 0.05 and 0.10 (no upper quantiles), so the SPod story is a LOW baseline band
# sitting beneath the data, with the pollution plumes clearly above it.  The note reports the share of readings BELOW
# the upper curve of the band (nominal = tau_hi), not a share inside.
#
# spod_panel(time, y, lower, upper, middle = NULL, tau_lo = 0.01, tau_hi = 0.10, tau_mid = 0.05, time_lab = "Time")
#   time    : numeric or POSIXct, length n (one reading per point)
#   y       : SPod reading, length n
#   lower   : posterior-mean curve at tau_lo, evaluated at `time` (length n); NULL draws only the `middle` curve
#   upper   : posterior-mean curve at tau_hi, evaluated at `time` (length n)
#   middle  : optional curve at tau_mid (e.g. the 0.05 baseline), drawn as the thin dark line
# Returns list(plot, share_below).  Not called by default.  When the E-18 curves exist, load them and add e.g.
#   sp <- spod_panel(d$time, d$y, d$q01, d$q10, d$q05); save_both(sp$plot, "readme_spod")
spod_panel <- function(time, y, lower, upper, middle = NULL, tau_lo = 0.01, tau_hi = 0.10, tau_mid = 0.05,
                       time_lab = "Time") {
  n <- length(y); stopifnot(length(time) == n, is.null(lower) || length(lower) == n, length(upper) == n)
  o <- order(time); x <- as.numeric(time)[o]
  if (is.null(lower)) lower <- upper                     # zero-width band: only the curve(s) show
  curve <- data.frame(x = x, q10 = lower[o], q90 = upper[o])  # band_panel's q10/q90 = generic lower/upper edges
  if (!is.null(middle)) curve$median <- middle[o]
  share_below <- mean(y < upper)
  note <- sprintf("%.1f%% of readings below the \u03c4 = %.2f curve (nominal %.0f%%)", 100 * share_below, tau_hi,
                  100 * tau_hi)
  p <- band_panel(pts = data.frame(x = x, y = y[o]), curve = curve, note = note,
                  title = "Air quality: SPod sensor baseline",
                  subtitle = paste0("Joint-sampler band between \u03c4 = ", tau_lo, " and ", tau_hi,
                                    if (!is.null(middle)) paste0("; line: \u03c4 = ", tau_mid) else ""),
                  xlab = time_lab, ylab = "Reading", point_size = 0.7, point_alpha = 0.7)
  list(plot = p, share_below = share_below)
}

# =====================================================================================================================
# Build
# =====================================================================================================================
cat("output folder:", show(out_dir), "| font:", FONT, "| per-curve bands:", SHOW_BANDS, "\n")
sfx <- if (SHOW_BANDS) "_bands" else ""

hero <- hero_panel()
gb <- growth_panel("boy")
gg <- growth_panel("girl")

if (!is.null(hero)) save_both(hero$plot, paste0("readme_hero_vs", hero$tag, sfx))
save_both(gb$plot, paste0("readme_growth_boys", sfx))
save_both(gg$plot, paste0("readme_growth_girls", sfx))

# Combined multi-panel image (grid layout, no extra packages): hero | growth boys
combine <- function(plots, stem, w_in = PNG_W_IN, h_in = 3.6) {
  draw <- function() {
    grid::grid.newpage()
    grid::grid.rect(gp = grid::gpar(fill = pal$bg, col = NA))
    lay <- grid::grid.layout(1, length(plots))
    grid::pushViewport(grid::viewport(layout = lay))
    for (i in seq_along(plots))
      print(plots[[i]] + theme(text = element_text(size = 8.5)),
            vp = grid::viewport(layout.pos.row = 1, layout.pos.col = i))
  }
  res <- 2400 / w_in                                             # always 2400 px wide, whatever the size in inches
  png(file.path(out_dir, paste0(stem, ".png")), width = 2400, height = round(h_in * res), res = res, type = "cairo",
      bg = pal$bg); draw(); invisible(dev.off())
  cairo_pdf(file.path(out_dir, paste0(stem, ".pdf")), width = w_in, height = h_in, family = FONT, bg = pal$bg)
  draw(); invisible(dev.off())
  cat("  wrote", show(file.path(out_dir, paste0(stem, ".{png,pdf}"))), "\n")
}
if (!is.null(hero)) {
  combine(list(hero$plot, gb$plot), paste0("readme_combined", hero$tag, sfx), w_in = 10.67)   # PNG 2400 px wide (225 dpi), PDF 10.67 x 3.6 in
} else cat("combined image skipped: no hero data\n")

cat(sprintf("SUMMARY share_inside: hero %s | growth boys %.4f | growth girls %.4f\n",
            if (is.null(hero)) "NA" else sprintf("%.4f", hero$share), gb$share, gg$share))
