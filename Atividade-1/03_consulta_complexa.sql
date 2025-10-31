
-- Descrição: Consulta complexa que atende a atividade 1 da materia

-- PERGUNTA DE NEGÓCIO:
-- "Qual é o produto mais vendido (em faturamento) de cada categoria?
--  Para cada um desses produtos, mostrar:
--  - O nome da categoria e do produto.
--  - O nome da loja e do fornecedor.
--  - O faturamento total gerado pelo produto.
--  - O tempo médio, em horas, entre a criação do pedido e o envio do pacote.""

WITH
  -- Passo 1: Calcular o faturamento de cada produto em todos os pedidos.
  FaturamentoPorProduto AS (
    SELECT
      produto_id,
      SUM(quantidade * preco_no_momento_da_compra) AS faturamento_total
    FROM Itens_Pedido
    GROUP BY
      produto_id
  ),
  
  -- Passo 2: Calcular o tempo médio de envio para cada pedido que já foi enviado.
  TempoDeEnvio AS (
    SELECT
      p.produto_id,
      -- Extrai a época (segundos desde 1970) de ambas as datas e calcula a diferença em horas.
      AVG(
        EXTRACT(EPOCH FROM (e.data_envio - ped.data_pedido)) / 3600
      ) AS tempo_medio_envio_horas
    FROM Pedidos AS ped
    JOIN Itens_Pedido AS p ON ped.pedido_id = p.pedido_id
    JOIN Envios AS e ON ped.pedido_id = e.pedido_id
    WHERE
      e.data_envio IS NOT NULL
    GROUP BY
      p.produto_id
  ),

  -- Passo 3: Rankear os produtos dentro de cada categoria com base no faturamento.
  RankingProdutos AS (
    SELECT
      p.produto_id,
      c.nome_categoria,
      p.nome_produto,
      l.nome_loja,
      f.nome_fornecedor,
      fp.faturamento_total,
      -- Função de Janela (WINDOW FUNCTION): numera cada produto dentro de sua partição de categoria,
      -- ordenando pelo faturamento. O nº 1 é o mais vendido.
      ROW_NUMBER() OVER (
        PARTITION BY c.categoria_id
        ORDER BY
          fp.faturamento_total DESC
      ) AS ranking_na_categoria
    FROM Produtos AS p
    JOIN Categorias AS c ON p.categoria_id = c.categoria_id
    JOIN Lojas AS l ON p.loja_id = l.loja_id
    LEFT JOIN Fornecedores AS f ON p.fornecedor_id = f.fornecedor_id
    JOIN FaturamentoPorProduto AS fp ON p.produto_id = fp.produto_id
  )

-- seleciona penas o produto de ranking 1 de cada categoria e junta com as métricas de tempo
SELECT
  r.nome_categoria AS "Categoria",
  r.nome_produto AS "Produto Mais Vendido",
  r.faturamento_total AS "Faturamento Total",
  r.nome_loja AS "Vendido Pela Loja",
  r.nome_fornecedor AS "Fornecedor",
  ROUND(te.tempo_medio_envio_horas, 2) AS "Tempo Médio de Envio (Horas)"
FROM RankingProdutos AS r
LEFT JOIN TempoDeEnvio AS te ON r.produto_id = te.produto_id
WHERE
  r.ranking_na_categoria = 1
ORDER BY
  "Faturamento Total" DESC;