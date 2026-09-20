# Renders the English version of the site (folder `_en/`) into `docs/en/`.
#
# This script is called automatically by Quarto after the main (Portuguese)
# site is rendered -- see `post-render` in `_quarto.yml`. It is needed because
# the English site is a separate Quarto project (its own navbar/footer in
# English), and rendering the main site cleans the `docs/` folder.
#
# You can also run it by hand from the project root:
#   quarto render _en

if (!dir.exists("_en")) {
  stop("Folder '_en' not found. Run this script from the project root.")
}

# When Quarto calls this script after rendering a single page (e.g. the
# "Render" button on one .qmd), there is no need to rebuild the whole English
# site. It only runs after a full "Render Website" -- or when you run it by hand.
called_by_quarto <- nzchar(Sys.getenv("QUARTO_PROJECT_DIR"))
if (called_by_quarto && !identical(Sys.getenv("QUARTO_PROJECT_RENDER_ALL"), "1")) {
  message("\nPartial render: skipping the English site (use Render Website to rebuild it).")
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

message("\nRendering the English site (_en -> docs/en) ...")
status <- 127L
for (q in candidates) {
  status <- suppressWarnings(system2(q, c("render", "_en")))
  if (!identical(as.integer(status), 127L)) break   # 127 = command not found
}

if (!identical(as.integer(status), 0L)) {
  stop("Rendering the English site failed. Run `quarto render _en` in the terminal to see the error.")
}
