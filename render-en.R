# Renders the translated versions of the site -- English (`_en/` -> `docs/en/`)
# and Spanish (`_es/` -> `docs/es/`).
# (The file keeps its original name, `render-en.R`, so `_quarto.yml` did not need
# to change; it now renders every translated version listed in `sites` below.)
#
# This script is called automatically by Quarto after the main (Portuguese)
# site is rendered -- see `post-render` in `_quarto.yml`. It is needed because
# each translated site is a separate Quarto project (its own navbar/footer in
# its own language), and rendering the main site cleans the `docs/` folder.
#
# You can also run it by hand from the project root:
#   quarto render _en
#   quarto render _es

sites <- c("_en", "_es")

for (s in sites) {
  if (!dir.exists(s)) {
    stop("Folder '", s, "' not found. Run this script from the project root.")
  }
}

# When Quarto calls this script after rendering a single page (e.g. the
# "Render" button on one .qmd), there is no need to rebuild the translated
# sites. It only runs after a full "Render Website" -- or when you run it by hand.
called_by_quarto <- nzchar(Sys.getenv("QUARTO_PROJECT_DIR"))
if (called_by_quarto && !identical(Sys.getenv("QUARTO_PROJECT_RENDER_ALL"), "1")) {
  message("\nPartial render: skipping the English and Spanish sites (use Render Website to rebuild them).")
  quit(save = "no", status = 0)
}

# Prefer the same Quarto that is rendering the main site; fall back to the
# `quarto` found in the PATH.
candidates <- "quarto"
bin <- Sys.getenv("QUARTO_BIN_PATH")
if (nzchar(bin)) {
  own <- file.path(bin, c("quarto.exe", "quarto.cmd", "quarto"))
  candidates <- c(own[file.exists(own)], candidates)
}

for (s in sites) {
  message("\nRendering the site in '", s, "' ...")
  status <- 127L
  for (q in candidates) {
    status <- suppressWarnings(system2(q, c("render", s)))
    if (!identical(as.integer(status), 127L)) break   # 127 = command not found
  }

  if (!identical(as.integer(status), 0L)) {
    stop("Rendering '", s, "' failed. Run `quarto render ", s, "` in the terminal to see the error.")
  }
}
