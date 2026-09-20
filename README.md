Neste repositório compartilharemos os principais produtos do projeto "Popularização do uso da Assinatura Espectral da Espécie na identificação das árvores do Manejo Florestal Sustentável na Amazônia - SPECTRA POP" (Programa Mulher Faz Ciência – FAPEAM – Edital n.º 006/2024), coordenado pela Dra. Flávia Durgante.


## Estrutura do site (PT/EN)

- O site em português é o projeto Quarto da raiz (`_quarto.yml`) e é publicado em `docs/`.
- O site em inglês é um projeto Quarto separado, com sua própria barra de menu, na pasta `_en/`, e é publicado em `docs/en/` (https://spectrapop.github.io/en/).
- Ao renderizar o site (botão *Render Website* ou `quarto render`), o script `render-en.R` roda automaticamente no final e renderiza também a versão em inglês. Para renderizar só o inglês: `quarto render _en`.
- Ao criar uma página nova, crie a página correspondente em `_en/` e inclua o par de endereços em `lang-switch.js` (para o seletor de idioma levar à página equivalente).
- A página *Resultados* (`resultados.qmd` / `_en/results.qmd`) monta um relatório do projeto. Os números de cursos oficiais, minicursos, pessoas capacitadas, artigos, preprints, livros, resumos, palestras, eventos, aplicações web e estudantes são **contados automaticamente** a partir de `publicacoes.qmd` (cada curso, minicurso e disciplina precisa ter "Pessoas capacitadas: N"). Os números do acervo espectral (espectros, espécies, exsicatas) ficam em `dados/resultados.yml`. Depois de editar, é só renderizar o site.
