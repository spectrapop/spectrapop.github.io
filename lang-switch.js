<script>
/*
  Language switch (PT <-> EN).
  Makes the "Português / English" items of the navbar language menu point to
  the equivalent page in the other language (when it exists), instead of just
  the home page. If a page is not listed below, the link falls back to the
  home page of the other language (which is what _quarto.yml already sets).

  When you add a new page to the site, add a line to PT_TO_EN.
  Paths are relative to each site's root: Portuguese = site root,
  English = /en/ (source folder _en/).
*/
document.addEventListener("DOMContentLoaded", function () {

  var PT_TO_EN = {
    "": "",
    "resultados.html": "results.html",
    "publicacoes.html": "publications.html",
    "bibliotecaespectral.html": "spectral-library.html",
    "herbarioinpa.html": "inpa-herbarium.html",
    "galeria.html": "gallery.html",
    "contato.html": "contact.html",
    "download.html": "download.html",
    "cursos/1curso_inpa.html": "courses/1course_inpa.html",
    "cursos/2curso_inpa.html": "courses/2course_inpa.html",
    "cursos/3curso_atto.html": "courses/3course_atto.html",
    "cursos/4curso_erbot.html": "courses/4course_erbot.html",
    "cursos/5curso_mpeg.html": "courses/5course_mpeg.html",
    "cursos/6curso_idsm.html": "courses/6course_idsm.html",
    "posts/spectrapop-em-um-esforco-global-de-digitalizacao-espectral.html": "posts/spectrapop-global-spectral-digitization-effort.html",
    "posts/nasce-o-projeto-herbspectra-amazonia.html": "posts/herbspectra-amazonia-project-is-born.html",
    "posts/conheca-nossos-pibics-2025.html": "posts/meet-our-pibic-students-2025.html",
    "posts/novo-artigo-confirma-o-potencial-da-espectroscopia-na-amazonia.html": "posts/new-article-confirms-potential-of-spectroscopy-in-amazonia.html"
  };

  var EN_TO_PT = {};
  Object.keys(PT_TO_EN).forEach(function (pt) { EN_TO_PT[PT_TO_EN[pt]] = pt; });

  // Root of the current Quarto project (site root for PT, /en/ for EN)
  var meta = document.querySelector('meta[name="quarto:offset"]');
  var projectRoot = new URL(meta ? meta.content : "./", window.location.href);
  var isEnglish = /\/en\/$/.test(projectRoot.pathname);
  var siteRoot = isEnglish ? new URL("../", projectRoot) : projectRoot;
  var enRoot = new URL("en/", siteRoot);

  // Path of this page relative to its own project root
  var rel = window.location.pathname.slice(projectRoot.pathname.length);
  rel = rel.replace(/index\.html$/, "");
  if (rel !== "" && !/\/$/.test(rel) && !/\.html$/.test(rel)) rel += ".html";
  if (/\/$/.test(rel)) rel = "";

  var target = isEnglish ? EN_TO_PT[rel] : PT_TO_EN[rel];
  if (target === undefined) return;   // unknown page: keep the home page links

  document.querySelectorAll(".navbar .dropdown-menu a.dropdown-item").forEach(function (a) {
    var label = a.textContent || "";
    if (!isEnglish && /English/.test(label)) {
      a.href = new URL(target, enRoot).href;
    } else if (isEnglish && /Portugu/.test(label)) {
      a.href = new URL(target, siteRoot).href;
    }
  });

});
</script>
