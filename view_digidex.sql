-- View consolidada do catálogo DigiDex.
-- Execute após schema.sql; pode ser reaplicada para atualizar a view existente.

CREATE OR REPLACE VIEW vw_digidex AS
SELECT
    d.id,
    d.nome,
    d.imagem_url,
    d.anticorpo_x,
    d.ano_lancamento,
    (SELECT STRING_AGG(n.nome, ', ' ORDER BY n.nome)
       FROM digimon_niveis AS dn
       JOIN niveis AS n ON n.id = dn.nivel_id
      WHERE dn.digimon_id = d.id) AS niveis,
    (SELECT STRING_AGG(a.nome, ', ' ORDER BY a.nome)
       FROM digimon_atributos AS da
       JOIN atributos AS a ON a.id = da.atributo_id
      WHERE da.digimon_id = d.id) AS atributos,
    (SELECT STRING_AGG(t.nome, ', ' ORDER BY t.nome)
       FROM digimon_tipos AS dt
       JOIN tipos AS t ON t.id = dt.tipo_id
      WHERE dt.digimon_id = d.id) AS tipos,
    (SELECT STRING_AGG(g.nome, ', ' ORDER BY g.nome)
       FROM digimon_grupos AS dg
       JOIN grupos AS g ON g.id = dg.grupo_id
      WHERE dg.digimon_id = d.id) AS grupos,
    COALESCE(
        (SELECT JSONB_AGG(
                    JSONB_BUILD_OBJECT(
                        'id', h.id,
                        'nome', h.nome,
                        'traducao', h.traducao,
                        'descricao', h.descricao
                    ) ORDER BY h.nome, h.id
                )
           FROM digimon_habilidades AS dh
           JOIN habilidades AS h ON h.id = dh.habilidade_id
          WHERE dh.digimon_id = d.id),
        '[]'::JSONB
    ) AS habilidades,
    COALESCE(
        (SELECT JSONB_AGG(
                    JSONB_BUILD_OBJECT(
                        'id', destino.id,
                        'nome', destino.nome,
                        'imagem_url', destino.imagem_url,
                        'condicao', e.condicao
                    ) ORDER BY destino.nome, destino.id
                )
           FROM evolucoes AS e
           JOIN digimon AS destino ON destino.id = e.digimon_destino_id
          WHERE e.digimon_origem_id = d.id),
        '[]'::JSONB
    ) AS evolucoes_para,
    COALESCE(
        (SELECT JSONB_AGG(
                    JSONB_BUILD_OBJECT(
                        'id', origem.id,
                        'nome', origem.nome,
                        'imagem_url', origem.imagem_url,
                        'condicao', e.condicao
                    ) ORDER BY origem.nome, origem.id
                )
           FROM evolucoes AS e
           JOIN digimon AS origem ON origem.id = e.digimon_origem_id
          WHERE e.digimon_destino_id = d.id),
        '[]'::JSONB
    ) AS evolucoes_de
FROM digimon AS d;

