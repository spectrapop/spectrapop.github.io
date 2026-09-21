# =============================================================================
# Página "Resultados" / "Results"
#
# Este arquivo é lido por resultados.qmd (PT), _en/results.qmd (EN) e
# _es/resultados.qmd (ES).
# Ele calcula os números da página e monta os cartões (cards) em HTML.
#
#  * Números AUTOMÁTICOS (contados a cada renderização a partir de
#    publicacoes.qmd): artigos, preprints, livros e relatórios, resumos,
#    palestras, cursos oficiais, minicursos, pessoas capacitadas (soma dos
#    "Pessoas capacitadas: N" de cursos, minicursos e disciplinas), eventos,
#    aplicações web e estudantes (doutorado / mestrado / graduação).
#  * Números MANUAIS (vêm do dashboard / banco de dados, então você digita):
#    ficam em dados/resultados.yml  (espectros, espécies, exsicatas).
#
# Não precisa editar este arquivo para atualizar a página.
# =============================================================================

resultados_raiz <- function() {
  if (file.exists(file.path("dados", "resultados.yml"))) "." else ".."
}

# ---- leitura de texto -------------------------------------------------------

.ler_linhas <- function(arq) {
  x <- readLines(arq, warn = FALSE, encoding = "UTF-8")
  sub("\r$", "", x)
}

# Linhas de uma seção (título regex + nível) até o próximo título de nível <= ao dela
.secao <- function(linhas, titulo_regex, nivel) {
  h   <- grep("^#{2,4} ", linhas)
  niv <- nchar(sub("^(#+) .*", "\\1", linhas[h]))
  cand <- h[niv == nivel & grepl(titulo_regex, linhas[h])]
  if (!length(cand)) return(character(0))
  ini  <- cand[1]
  prox <- h[h > ini & niv <= nivel]
  fim  <- if (length(prox)) prox[1] - 1 else length(linhas)
  if (ini + 1 > fim) return(character(0))
  linhas[(ini + 1):fim]
}

# Cada registro da página começa numa linha com um ícone (news.png, user.png ...).
# Devolve o texto de cada registro (do ícone até o próximo ícone da mesma seção).
.registros <- function(sec, icone) {
  padrao <- paste0("assets/icons/", icone, "\\.png")
  ini <- grep(padrao, sec)
  if (!length(ini)) return(character(0))
  fim <- c(ini[-1] - 1, length(sec))
  mapply(function(a, b) paste(sec[a:b], collapse = " "), ini, fim, USE.NAMES = FALSE)
}

.n <- function(sec, icone) length(.registros(sec, icone))

# ---- contagens automáticas --------------------------------------------------

resultados_contar <- function(raiz = resultados_raiz()) {

  L <- .ler_linhas(file.path(raiz, "publicacoes.qmd"))

  artigos_sec   <- .secao(L, "Artigos", 2)
  art_reg       <- .registros(artigos_sec, "news")
  eh_preprint   <- grepl("preprint", art_reg, ignore.case = TRUE)

  # Estudantes: cada registro de "Orientações" começa com o ícone user.png.
  # O nível é a primeira palavra encontrada entre Doutor*/Mestr*/Gradua*.
  ori_reg <- .registros(.secao(L, "Orienta", 2), "user")
  nivel_de <- function(txt) {
    pos <- c(doutorado = regexpr("Doutor", txt, ignore.case = TRUE),
             mestrado  = regexpr("Mestr",  txt, ignore.case = TRUE),
             graduacao = regexpr("Gradua", txt, ignore.case = TRUE))
    pos[pos < 0] <- NA
    if (all(is.na(pos))) NA_character_ else names(which.min(pos))
  }
  niveis <- vapply(ori_reg, nivel_de, character(1))

  # Eventos distintos: nome do evento = texto depois de "In:" até a primeira vírgula.
  ev_sec <- .secao(L, "eventos", 2)
  ev <- grep("(<em>In:</em>|\\*In:\\*)", ev_sec, value = TRUE)
  ev <- sub(".*(<em>In:</em>|\\*In:\\*)\\s*", "", ev)
  ev <- sub(",.*$", "", ev)
  ev <- gsub("[^[:alnum:]]", "", tolower(ev))

  # Pessoas capacitadas: cada registro traz "Pessoas capacitadas: N"
  # (aceita também "People trained: N" e a grafia "capacidadas").
  soma_pessoas <- function(reg) {
    m <- regmatches(reg, regexpr("(Pessoas capaci[a-z]*|People trained): *[0-9]+", reg))
    sum(as.numeric(sub(".*: *", "", m)))
  }
  cur_reg  <- .registros(.secao(L, "Cursos oficiais", 2), "learning")
  mini_reg <- .registros(.secao(L, "Minicursos", 3), "learning")
  disc_reg <- .registros(.secao(L, "Disciplinas", 2), "learning")
  todos    <- c(cur_reg, mini_reg, disc_reg)
  sem_num  <- sum(!grepl("(Pessoas capaci[a-z]*|People trained): *[0-9]+", todos))

  list(
    cursos_oficiais  = length(cur_reg),
    n_minicursos     = length(mini_reg),
    n_disciplinas    = length(disc_reg),
    tr_cursos        = soma_pessoas(cur_reg),
    tr_mini          = soma_pessoas(mini_reg),
    tr_disc          = soma_pessoas(disc_reg),
    sem_numero       = sem_num,
    artigos          = sum(!eh_preprint),
    preprints        = sum(eh_preprint),
    livros           = .n(.secao(L, "Livros", 2), "news"),
    resumos          = .n(.secao(L, "Resumos", 3), "news"),
    palestras        = .n(.secao(L, "Palestras", 3), "presentation"),
    eventos          = length(unique(ev[nzchar(ev)])),
    apps             = .n(.secao(L, "Aplica", 2), "app"),
    doutorado        = sum(niveis == "doutorado", na.rm = TRUE),
    mestrado         = sum(niveis == "mestrado",  na.rm = TRUE),
    graduacao        = sum(niveis == "graduacao", na.rm = TRUE)
  )
}

# ---- junta automáticos + manuais (dados/resultados.yml) ---------------------

resultados_dados <- function(raiz = resultados_raiz()) {
  a <- resultados_contar(raiz)
  y <- yaml::yaml.load(paste(.ler_linhas(file.path(raiz, "dados", "resultados.yml")), collapse = "\n"))
  if (is.null(y)) y <- list()
  pega <- function(nome) { v <- y[[nome]]; if (is.null(v) || identical(v, "")) NULL else v }

  r <- a
  r$cursos_total <- a$cursos_oficiais + a$n_minicursos
  r$treinados    <- a$tr_cursos + a$tr_mini + a$tr_disc

  r$estudantes <- a$doutorado + a$mestrado + a$graduacao

  r$espectros <- pega("espectros_coletados")
  r$especies  <- pega("especies_com_espectros")
  r$exsicatas <- pega("exsicatas")
  r$atualizado_em <- pega("atualizado_em")

  # correções manuais pontuais (bloco "override" do yml)
  ov <- y[["override"]]
  for (k in names(ov)) if (!is.null(ov[[k]])) r[[k]] <- ov[[k]]

  faltam <- c(espectros = is.null(r$espectros), especies = is.null(r$especies), exsicatas = is.null(r$exsicatas))
  if (any(faltam)) {
    cat("\n[Resultados] Preencha em dados/resultados.yml: ",
        paste(names(faltam)[faltam], collapse = ", "),
        " (os cartões ficam ocultos até lá).\n", sep = "", file = stderr())
  }
  if (a$sem_numero > 0) {
    cat("\n[Resultados] ", a$sem_numero, " curso(s)/minicurso(s)/disciplina(s) em publicacoes.qmd ",
        "sem \"Pessoas capacitadas: N\" (contados como 0).\n", sep = "", file = stderr())
  }
  r
}

# ---- textos por idioma ------------------------------------------------------

.txt <- list(
  pt = list(
    sep = ".", mes = c("janeiro","fevereiro","março","abril","maio","junho","julho",
                       "agosto","setembro","outubro","novembro","dezembro"),
    cursos = "Cursos e minicursos", treinados = "Pessoas capacitadas",
    treinados_d = "", estudantes = "Estudantes orientados",
    espectros = "Espectros coletados", especies = "Espécies com espectros",
    exsicatas = "Exsicatas amostradas", apps = "Aplicações web",
    artigos = "Artigos científicos", preprints = "Preprints",
    livros = "Livros e relatórios", resumos = "Resumos em eventos",
    palestras = "Palestras e simpósios", eventos = "Eventos científicos",
    eventos_d = "com participação do projeto",
    curso = c("curso oficial", "cursos oficiais"),
    mini  = c("minicurso em evento", "minicursos em eventos"),
    tr_cursos = "em cursos", tr_mini = "em minicursos",
    tr_disc = c("em disciplina", "em disciplinas"),
    dout = "doutorado", mest = "mestrado", grad = "graduação",
    apps_d = "dashboard e leitores de espectros"
  ),
  en = list(
    sep = ",", mes = month.name,
    cursos = "Courses and short courses", treinados = "People trained",
    treinados_d = "", estudantes = "Students supervised",
    espectros = "Spectra collected", especies = "Species with spectra",
    exsicatas = "Herbarium specimens sampled", apps = "Web applications",
    artigos = "Journal articles", preprints = "Preprints",
    livros = "Books and reports", resumos = "Conference abstracts",
    palestras = "Talks and symposia", eventos = "Scientific events",
    eventos_d = "with project participation",
    curso = c("official course", "official courses"),
    mini  = c("short course at an event", "short courses at events"),
    tr_cursos = "in courses", tr_mini = "in short courses",
    tr_disc = c("in a graduate course", "in graduate courses"),
    dout = "PhD", mest = "MSc", grad = "undergraduate",
    apps_d = "dashboard and spectra readers"
  ),
  # Espanhol (América Latina). Separador de milhar = espaço fino (sem quebra),
  # que evita a confusão ponto/vírgula entre países.
  es = list(
    sep = " ", mes = c("enero","febrero","marzo","abril","mayo","junio","julio",
                            "agosto","septiembre","octubre","noviembre","diciembre"),
    cursos = "Cursos y minicursos", treinados = "Personas capacitadas",
    treinados_d = "", estudantes = "Estudiantes asesorados",
    espectros = "Espectros colectados", especies = "Especies con espectros",
    exsicatas = "Ejemplares de herbario muestreados", apps = "Aplicaciones web",
    artigos = "Artículos científicos", preprints = "Preprints",
    livros = "Libros e informes", resumos = "Resúmenes en eventos",
    palestras = "Conferencias y simposios", eventos = "Eventos científicos",
    eventos_d = "con participación del proyecto",
    curso = c("curso oficial", "cursos oficiales"),
    mini  = c("minicurso en evento", "minicursos en eventos"),
    tr_cursos = "en cursos", tr_mini = "en minicursos",
    tr_disc = c("en un curso de posgrado", "en cursos de posgrado"),
    dout = "doctorado", mest = "maestría", grad = "pregrado",
    apps_d = "dashboard y lectores de espectros"
  )
)

resultados_data_texto <- function(lang = "pt", hoje = Sys.Date()) {
  t <- .txt[[lang]]
  m <- as.integer(format(hoje, "%m"))
  if (lang == "pt") paste0(t$mes[m], "/", format(hoje, "%Y"))
  else if (lang == "es") paste0(t$mes[m], " de ", format(hoje, "%Y"))
  else paste0(t$mes[m], " ", format(hoje, "%Y"))
}

# ---- ícones (SVG simples, 24x24) -------------------------------------------

.icones <- list(
  cursos    = '<path d="M3 8l9-4 9 4-9 4-9-4z"/><path d="M7 10.5V15c0 1 2.2 2.5 5 2.5s5-1.5 5-2.5v-4.5"/>',
  treinados = '<circle cx="9" cy="8" r="3"/><path d="M3 19c0-3.3 2.7-6 6-6s6 2.7 6 6"/><circle cx="17" cy="9" r="2.3"/><path d="M16 13.2c2.8.2 5 2.3 5 5.3"/>',
  estudantes= '<path d="M12 6c-2-1.5-5-2-8-2v14c3 0 6 .5 8 2 2-1.5 5-2 8-2V4c-3 0-6 .5-8 2z"/><path d="M12 6v14"/>',
  espectros = '<path d="M2 12h3l2-6 3 12 3-9 2 3h7"/>',
  especies  = '<path d="M5 19c0-8 5-14 15-14 0 10-6 15-14 15"/><path d="M5 19c3-4 6-7 10-9"/>',
  exsicatas = '<rect x="5" y="3" width="14" height="18" rx="1.5"/><path d="M12 18v-8"/><path d="M12 13c-2 0-3-1-3-3 2 0 3 1 3 3z"/><path d="M12 15c2 0 3-1 3-3-2 0-3 1-3 3z"/>',
  apps      = '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 9h18"/><path d="M7 6.5h.01M10 6.5h.01"/>',
  artigos   = '<path d="M7 3h8l4 4v14H7z"/><path d="M15 3v4h4"/><path d="M10 12h6M10 16h6"/>',
  preprints = '<path d="M7 3h8l4 4v14H7z" stroke-dasharray="2.5 2"/><path d="M15 3v4h4"/><path d="M10 12h6M10 16h6"/>',
  livros    = '<path d="M5 4h11a3 3 0 013 3v13H8a3 3 0 01-3-3z"/><path d="M5 17a3 3 0 013-3h11"/>',
  resumos   = '<rect x="4" y="4" width="16" height="16" rx="2"/><path d="M8 9h8M8 13h8M8 17h5"/>',
  palestras = '<rect x="3" y="4" width="18" height="12" rx="1.5"/><path d="M12 16v4M8 20h8"/>',
  eventos   = '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>'
)

# ---- cartões ----------------------------------------------------------------

.fmt <- function(x, sep) {
  formatC(round(as.numeric(x)), format = "d", big.mark = sep,
          decimal.mark = if (sep == ".") "," else ".")
}
.pl  <- function(n, formas) if (n == 1) formas[1] else formas[2]
.esc <- function(x) htmltools::htmlEscape(x)

# chaves: vetor com os cartões desejados, na ordem. Cartões sem valor (NULL) são omitidos.
resultados_cards <- function(r, chaves, lang = "pt") {
  t <- .txt[[lang]]
  sep <- t$sep
  cartao <- function(k) {
    val <- switch(k,
      cursos = r$cursos_total, treinados = r$treinados, estudantes = r$estudantes,
      espectros = r$espectros, especies = r$especies, exsicatas = r$exsicatas,
      apps = r$apps, artigos = r$artigos, preprints = r$preprints, livros = r$livros,
      resumos = r$resumos, palestras = r$palestras, eventos = r$eventos)
    if (is.null(val)) return(NULL)
    det <- switch(k,
      cursos = c(paste(r$cursos_oficiais, .pl(r$cursos_oficiais, t$curso)),
                 paste(r$n_minicursos, .pl(r$n_minicursos, t$mini))),
      treinados = c(
        if (r$tr_cursos > 0) paste(.fmt(r$tr_cursos, sep), t$tr_cursos),
        if (r$tr_mini   > 0) paste(.fmt(r$tr_mini, sep),   t$tr_mini),
        if (r$tr_disc   > 0) paste(.fmt(r$tr_disc, sep),   .pl(r$n_disciplinas, t$tr_disc))),
      estudantes = c(paste(r$doutorado, t$dout), paste(r$mestrado, t$mest),
                     paste(r$graduacao, t$grad)),
      eventos = t$eventos_d,
      apps = t$apps_d,
      character(0))
    det <- paste(.esc(det), collapse = " &middot; ")
    paste0(
      '<div class="res-card">\n',
      '<svg viewBox="0 0 24 24" aria-hidden="true">', .icones[[k]], '</svg>\n',
      '<div class="res-num">', .fmt(val, sep), '</div>\n',
      '<div class="res-label">', .esc(t[[k]]), '</div>\n',
      if (nzchar(det)) paste0('<div class="res-detail">', det, '</div>\n') else "",
      '</div>\n')
  }
  cards <- Filter(Negate(is.null), lapply(chaves, cartao))
  if (!length(cards)) return(knitr::asis_output(""))
  n <- length(cards)
  cols <- if (n %in% c(3, 6, 9)) " res-cols-3" else if (n %in% c(4, 8)) " res-cols-4" else ""
  knitr::asis_output(paste0('<div class="res-grid', cols, '">\n', paste(cards, collapse = ""), '</div>\n'))
}
