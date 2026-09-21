Neste repositório compartilharemos os principais produtos do projeto "Popularização do uso da Assinatura Espectral da Espécie na identificação das árvores do Manejo Florestal Sustentável na Amazônia - SPECTRA POP" (Programa Mulher Faz Ciência – FAPEAM – Edital n.º 006/2024), coordenado pela Dra. Flávia Durgante.


## Estrutura do site (PT/EN/ES)

- O site em português é o projeto Quarto da raiz (`_quarto.yml`) e é publicado em `docs/`.
- O site em inglês é um projeto Quarto separado, com sua própria barra de menu, na pasta `_en/`, e é publicado em `docs/en/` (https://spectrapop.github.io/en/).
- O site em espanhol (América Latina) segue o mesmo esquema: projeto Quarto separado na pasta `_es/`, publicado em `docs/es/` (https://spectrapop.github.io/es/). As páginas em espanhol se chamam `resultados`, `publicaciones`, `biblioteca-espectral`, `herbario-inpa`, `galeria`, `contacto` e `descargas`; os cursos mantêm os nomes de `cursos/`.
- Ao renderizar o site (botão *Render Website* ou `quarto render`), o script `render-en.R` roda automaticamente no final e renderiza também as versões em inglês e em espanhol. Para renderizar só uma delas: `quarto render _en` ou `quarto render _es`.
- Ao criar uma página nova, crie a página correspondente em `_en/` e em `_es/` e inclua os três endereços na lista `PAGES` de `lang-switch.js` (para o seletor de idioma levar à página equivalente).
- A página *Resultados* (`resultados.qmd` / `_en/results.qmd` / `_es/resultados.qmd`) monta um relatório do projeto. Os números de cursos oficiais, minicursos, pessoas capacitadas, artigos, preprints, livros, resumos, palestras, eventos, aplicações web e estudantes são **contados automaticamente** a partir de `publicacoes.qmd` (cada curso, minicurso e disciplina precisa ter "Pessoas capacitadas: N"). Os números do acervo espectral (espectros, espécies, exsicatas) ficam em `dados/resultados.yml`. Depois de editar, é só renderizar o site. O script `dados/limpar-cache.R` (chamado por `pre-render` nos `_quarto.yml`) apaga o cache da página antes de renderizar; sem ele o Quarto podia reaproveitar o número antigo (cache em `.quarto/_freeze/`) ao renderizar só a página de Resultados.
