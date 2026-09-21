# =============================================================================
# Roda automaticamente ANTES de renderizar (veja `pre-render` nos _quarto.yml).
#
# Por que existe: as páginas de Resultados (resultados.qmd, _en/results.qmd,
# _es/resultados.qmd) calculam os números lendo o publicacoes.qmd. Só que o
# Quarto guarda o resultado do código em `.quarto/_freeze/` e o reaproveita
# enquanto o texto do PRÓPRIO resultados.qmd não mudar -- ele não percebe que
# o publicacoes.qmd mudou. Resultado: a página continuava mostrando o número
# antigo de pessoas capacitadas.
#
# Este script apaga esse cache só das páginas de Resultados, então elas sempre
# recalculam os números na hora de renderizar.
# =============================================================================

proj <- Sys.getenv("QUARTO_PROJECT_DIR", unset = ".")
cache <- file.path(proj, ".quarto", "_freeze", c("resultados", "results"))
cache <- cache[dir.exists(cache)]
if (length(cache)) unlink(cache, recursive = TRUE)
