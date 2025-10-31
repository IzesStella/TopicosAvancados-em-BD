-- Script para inserir dados de exemplo em todas as tabelas.

-- 1. Inserindo dados em tabelas sem dependências
INSERT INTO Usuarios (nome, email, senha) VALUES
('Ana Julia', 'anajulia@email.com', 'senha123'), -- Será Vendedora e Compradora
('Carlos Moura', 'carlosmoura@email.com', 'senha456'), -- Será apenas Comprador
('Beatriz Lima', 'beatriz@email.com', 'senha789'); -- Será Vendedora

INSERT INTO Categorias (nome_categoria) VALUES
('K-Pop'),
('Eletrônicos'),
('Livros');

INSERT INTO Transportadoras (nome_transportadora) VALUES
('Correios'),
('Jadlog'),
('Loggi');

INSERT INTO Armazens (nome_armazem, cidade, estado) VALUES
('Centro de Distribuição SP', 'São Paulo', 'SP'),
('Centro de Distribuição RJ', 'Rio de Janeiro', 'RJ');

-- 2. Inserindo dados que dependem da primeira leva
INSERT INTO Enderecos (usuario_id, cep, logradouro, numero, cidade, estado) VALUES
(1, '50000-000', 'Rua das Flores', '100', 'Recife', 'PE'),
(2, '20000-000', 'Avenida Central', '500', 'Rio de Janeiro', 'RJ');

INSERT INTO Lojas (usuario_dono_id, nome_loja, descricao) VALUES
(1, 'Albuns-KpopBR', 'Sua loja de álbuns de K-Pop direto da Coreia.'),
(3, 'Tech Imports', 'Gadgets e eletrônicos importados.');

-- 3. Inserindo Fornecedores e Produtos
INSERT INTO Fornecedores (loja_id, nome_fornecedor) VALUES
(1, 'Distribuidora YG'),
(1, 'Distribuidora JYP'),
(2, 'Fornecedor Shenzhen Tech');

INSERT INTO Produtos (loja_id, categoria_id, fornecedor_id, nome_produto, descricao, preco) VALUES
-- Produtos da Loja ficticia "Albuns-KpopBR"
(1, 1, 1, 'Álbum BIGBANG - MADE', 'Full album com photobook', 150.00),
(1, 1, 2, 'Álbum TWICE - Formula of Love', 'Inclui photocards aleatórios', 180.50),
-- Produtos da Loja ficticia "Tech Imports"
(2, 2, 3, 'Fone de Ouvido Bluetooth TWS', 'Fone sem fio com cancelamento de ruído', 250.00),
(2, 2, 3, 'Mouse Gamer RGB', 'Mouse com 16000 DPI e luzes customizáveis', 300.00),
-- Produto tipo livro da loja de K-Pop para teste de categoria
(1, 3, 1, 'Biografia Oficial BLACKPINK', 'A história do maior girl group', 80.00);


-- 4. Inserindo no Inventário
INSERT INTO Inventario (produto_id, armazem_id, quantidade_disponivel) VALUES
(1, 1, 50),  -- Álbum BIGBANG em SP
(2, 1, 30),  -- Álbum TWICE em SP
(3, 2, 100), -- Fone de Ouvido no RJ
(4, 2, 75),  -- Mouse Gamer no RJ
(5, 1, 200); -- Biografia em SP

-- 5. Simulando uma Compra (Pedido com itens de LOJAS DIFERENTES)
-- Carlos Moura (usuario_id=2) compra um álbum da Loja 1 e um fone da Loja 2
INSERT INTO Pedidos (usuario_id, endereco_entrega_id, status_pedido) VALUES
(2, 2, 'Pagamento Aprovado');

INSERT INTO Itens_Pedido (pedido_id, produto_id, quantidade, preco_no_momento_da_compra) VALUES
(1, 2, 1, 180.50), -- Comprou 1 Álbum do TWICE
(1, 3, 1, 245.00); -- Comprou 1 Fone (com um pequeno desconto na hora da compra)

-- Ana Julia (usuario_id=1) compra um mouse para ela mesma
INSERT INTO Pedidos (usuario_id, endereco_entrega_id, status_pedido) VALUES
(1, 1, 'Pagamento Aprovado');
INSERT INTO Itens_Pedido (pedido_id, produto_id, quantidade, preco_no_momento_da_compra) VALUES
(2, 4, 2, 300.00); -- Comprou 2 mouses

-- 6. Simulando a Logística para o primeiro pedido
INSERT INTO Envios (pedido_id, transportadora_id, armazem_origem_id, codigo_rastreio, data_envio, previsao_entrega) VALUES
(1, 1, 2, 'BR123456789CD', (now() at time zone 'America/Sao_Paulo') + interval '1 day', current_date + interval '7 days'); -- Pedido sai do RJ

INSERT INTO Status_Envio (envio_id, status_descricao, localizacao) VALUES
(1, 'Em separação no armazém', 'Rio de Janeiro/RJ'),
(1, 'Pacote postado', 'Rio de Janeiro/RJ');