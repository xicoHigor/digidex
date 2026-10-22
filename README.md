# DigiDex

Enciclopédia interativa de Digimon com catálogo pesquisável, filtros, fichas detalhadas e uma estrutura PostgreSQL relacional.

## Abrir o site

- Site: https://xicohigor.github.io/digidex/
- Repositório: https://github.com/xicoHigor/digidex

## Arquivos

- `index.html`: interface em português.
- `catalog.js` e `catalog.json`: catálogo local de 1.488 registros com ID, nome e imagem.
- `schema.sql`: estrutura das 12 tabelas, índices e view `vw_digidex`.
- `view_digidex.sql`: cria ou atualiza a view consolidada com habilidades e evoluções.
- `seed_catalog.sql`: Digimon, níveis, atributos, tipos e grupos.
- `seed_skills.sql`: habilidades.
- `seed_relationships.sql`: relações dos Digimon com níveis, atributos, tipos, grupos e habilidades.
- `seed_evolutions.sql`: evoluções direcionadas, da origem para o destino.

## Carregar os dados no PostgreSQL

Execute os arquivos nesta ordem:

1. `schema.sql`
2. `seed_catalog.sql`
3. `seed_skills.sql`
4. `seed_relationships.sql`
5. `seed_evolutions.sql`
6. `view_digidex.sql` (atualiza a view também em bancos já existentes)

Os scripts de carga usam `ON CONFLICT`, então podem ser executados novamente para atualizar ou completar os registros.

O seed foi montado a partir das fichas detalhadas da [DAPI — Digimon API](https://digi-api.com/), consultadas em 22 de outubro de 2026. Ele inclui 1.488 Digimon, 9 níveis, 7 atributos, 154 tipos, 10 grupos, 3.780 habilidades e as relações de níveis, atributos, tipos, grupos, habilidades e evoluções disponíveis na fonte.

## Consultar a view

A view `vw_digidex` mostra um registro por Digimon, com seus dados básicos, níveis, atributos, tipos, grupos, habilidades e evoluções de entrada e saída. As habilidades e evoluções são retornadas como arrays JSONB; quando não há relações, o valor é `[]`.

```sql
SELECT id, nome, niveis, atributos, tipos, grupos,
       habilidades, evolucoes_para, evolucoes_de
FROM vw_digidex
ORDER BY id;
```

## Observação sobre os dados

A DAPI reúne dados de fontes oficiais e de fãs e não é afiliada à Bandai. Os IDs seguem os identificadores da API. Algumas informações, como descrição ou evolução, podem estar indisponíveis para registros específicos.

