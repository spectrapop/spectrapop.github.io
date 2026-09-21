<script>
/*
  Language switch (PT <-> EN <-> ES).
  Makes the "Português / English / Español" items of the navbar language menu
  point to the equivalent page in the other languages (when it exists), instead
  of just the home page. If a page is not listed below, the link falls back to
  the home page of the other language (which is what each _quarto.yml already
  sets).

  When you add a new page to the site, add a line to PAGES with the file name
  of the page in each language.
  Paths are relative to each site's root: Portuguese = site root,
  English = /en/ (source folder _en/), Spanish = /es/ (source folder _es/).
*/
document.addEventListener("DOMContentLoaded", function () {

  var PAGES = [
    { pt: "", en: "", es: "" },
    { pt: "resultados.html", en: "results.html", es: "resultados.html" },
    { pt: "publicacoes.html", en: "publications.html", es: "publicaciones.html" },
    { pt: "bibliotecaespectral.html", en: "spectral-library.html", es: "biblioteca-espectral.html" },
    { pt: "herbarioinpa.html", en: "inpa-herbarium.html", es: "herbario-inpa.html" },
    { pt: "galeria.html", en: "gallery.html", es: "galeria.html" },
    { pt: "contato.html", en: "contact.html", es: "contacto.html" },
    { pt: "download.html", en: "download.html", es: "descargas.html" },
    { pt: "cursos/1curso_inpa.html", en: "courses/1course_inpa.html", es: "cursos/1curso_inpa.html" },
    { pt: "cursos/2curso_inpa.html", en: "courses/2course_inpa.html", es: "cursos/2curso_inpa.html" },
    { pt: "cursos/3curso_atto.html", en: "courses/3course_atto.html", es: "cursos/3curso_atto.html" },
    { pt: "cursos/4curso_erbot.html", en: "courses/4course_erbot.html", es: "cursos/4curso_erbot.html" },
    { pt: "cursos/5curso_mpeg.html", en: "courses/5course_mpeg.html", es: "cursos/5curso_mpeg.html" },
    { pt: "cursos/6curso_idsm.html", en: "courses/6course_idsm.html", es: "cursos/6curso_idsm.html" },
    { pt: "posts/spectrapop-em-um-esforco-global-de-digitalizacao-espectral.html",
      en: "posts/spectrapop-global-spectral-digitization-effort.html",
      es: "posts/spectrapop-en-un-esfuerzo-global-de-digitalizacion-espectral.html" },
    { pt: "posts/nasce-o-projeto-herbspectra-amazonia.html",
      en: "posts/herbspectra-amazonia-project-is-born.html",
      es: "posts/nace-el-proyecto-herbspectra-amazonia.html" },
    { pt: "posts/conheca-nossos-pibics-2025.html",
      en: "posts/meet-our-pibic-students-2025.html",
      es: "posts/conozca-a-nuestros-pibics-2025.html" },
    { pt: "posts/novo-artigo-confirma-o-potencial-da-espectroscopia-na-amazonia.html",
      en: "posts/new-article-confirms-potential-of-spectroscopy-in-amazonia.html",
      es: "posts/nuevo-articulo-confirma-el-potencial-de-la-espectroscopia-en-la-amazonia.html" }
  ];

  // Root of the current Quarto project (site root for PT, /en/ or /es/ for the others)
  var meta = document.querySelector('meta[name="quarto:offset"]');
  var projectRoot = new URL(meta ? meta.content : "./", window.location.href);
  var current = /\/en\/$/.test(projectRoot.pathname) ? "en"
              : /\/es\/$/.test(projectRoot.pathname) ? "es" : "pt";
  var siteRoot = current === "pt" ? projectRoot : new URL("../", projectRoot);
  var roots = {
    pt: siteRoot,
    en: new URL("en/", siteRoot),
    es: new URL("es/", siteRoot)
  };

  // Path of this page relative to its own project root
  var rel = window.location.pathname.slice(projectRoot.pathname.length);
  rel = rel.replace(/index\.html$/, "");
  if (rel !== "" && !/\/$/.test(rel) && !/\.html$/.test(rel)) rel += ".html";
  if (/\/$/.test(rel)) rel = "";

  var page = null;
  for (var i = 0; i < PAGES.length; i++) {
    if (PAGES[i][current] === rel) { page = PAGES[i]; break; }
  }
  if (page === null) return;   // unknown page: keep the home page links

  var LABELS = { pt: /Portugu/, en: /English/, es: /Espa[nñ]ol/ };

  document.querySelectorAll(".navbar .dropdown-menu a.dropdown-item").forEach(function (a) {
    var label = a.textContent || "";
    ["pt", "en", "es"].forEach(function (lang) {
      if (lang !== current && LABELS[lang].test(label)) {
        a.href = new URL(page[lang], roots[lang]).href;
      }
    });
  });

});
</script>
