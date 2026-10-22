-- Estrutura inicial do banco da DigiDex (PostgreSQL).
-- Os IDs de digimon acompanham os IDs fornecidos pela DAPI.

CREATE TABLE IF NOT EXISTS digimon (
    id INT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    imagem_url TEXT,
    anticorpo_x BOOLEAN,
    ano_lancamento VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS niveis (
    id INT PRIMARY KEY,
    nome VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS atributos (
    id INT PRIMARY KEY,
    nome VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS tipos (
    id INT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS grupos (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    imagem_url TEXT
);

CREATE TABLE IF NOT EXISTS habilidades (
    id INT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    traducao VARCHAR(120),
    descricao TEXT
);

CREATE TABLE IF NOT EXISTS digimon_niveis (
    digimon_id INT NOT NULL REFERENCES digimon(id) ON DELETE CASCADE,
    nivel_id INT NOT NULL REFERENCES niveis(id) ON DELETE CASCADE,
    PRIMARY KEY (digimon_id, nivel_id)
);

CREATE TABLE IF NOT EXISTS digimon_atributos (
    digimon_id INT NOT NULL REFERENCES digimon(id) ON DELETE CASCADE,
    atributo_id INT NOT NULL REFERENCES atributos(id) ON DELETE CASCADE,
    PRIMARY KEY (digimon_id, atributo_id)
);

CREATE TABLE IF NOT EXISTS digimon_tipos (
    digimon_id INT NOT NULL REFERENCES digimon(id) ON DELETE CASCADE,
    tipo_id INT NOT NULL REFERENCES tipos(id) ON DELETE CASCADE,
    PRIMARY KEY (digimon_id, tipo_id)
);

CREATE TABLE IF NOT EXISTS digimon_grupos (
    digimon_id INT NOT NULL REFERENCES digimon(id) ON DELETE CASCADE,
    grupo_id INT NOT NULL REFERENCES grupos(id) ON DELETE CASCADE,
    PRIMARY KEY (digimon_id, grupo_id)
);

CREATE TABLE IF NOT EXISTS digimon_habilidades (
    digimon_id INT NOT NULL REFERENCES digimon(id) ON DELETE CASCADE,
    habilidade_id INT NOT NULL REFERENCES habilidades(id) ON DELETE CASCADE,
    PRIMARY KEY (digimon_id, habilidade_id)
);

-- Evolução orientada: Digimon de origem -> Digimon de destino.
CREATE TABLE IF NOT EXISTS evolucoes (
    digimon_origem_id INT NOT NULL REFERENCES digimon(id) ON DELETE CASCADE,
    digimon_destino_id INT NOT NULL REFERENCES digimon(id) ON DELETE CASCADE,
    condicao TEXT,
    PRIMARY KEY (digimon_origem_id, digimon_destino_id),
    CHECK (digimon_origem_id <> digimon_destino_id)
);

CREATE INDEX IF NOT EXISTS idx_digimon_nome ON digimon (nome);
CREATE INDEX IF NOT EXISTS idx_evolucoes_destino ON evolucoes (digimon_destino_id);

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

