# DigiDex

Primeira versão da enciclopédia de Digimon, inspirada na estrutura do projeto Pokédex: catálogo pesquisável, filtros, ficha detalhada e uma base PostgreSQL relacional.

## Abrir

Abra `index.html` no navegador. O catálogo básico fica junto do projeto em `catalog.js` e `catalog.json`; as fichas detalhadas e os filtros por nível e atributo consultam a DAPI quando usados.

## Arquivos

- `index.html`: interface navegável em português.
- `catalog.js` e `catalog.json`: snapshot local de 1.488 registros com ID, nome e imagem.
- `schema.sql`: estrutura relacional inicial para PostgreSQL.
- `seed_catalog.sql`: carga inicial do catálogo básico.

## Dados

O catálogo foi obtido em 22 de outubro de 2026 pela lista da [DAPI — Digimon API](https://digi-api.com/). A documentação informa que a base reúne fontes oficiais e de fãs, principalmente Wikimon, e que a API não é afiliada à Bandai. A interface usa os IDs dessa base, que identificam registros da API.

As fichas complementares mostram níveis, tipos, atributos, grupos, descrição, habilidades e evoluções conforme a disponibilidade de cada registro na DAPI. Algumas descrições estão em inglês porque são exibidas no idioma fornecido pela fonte.

## PostgreSQL

Execute `schema.sql` primeiro e depois `seed_catalog.sql`. A carga inicial inclui os IDs, nomes e URLs de imagem. Tabelas de níveis, tipos, atributos, grupos, habilidades e evoluções ficam prontas para receber os dados relacionais das fichas.

