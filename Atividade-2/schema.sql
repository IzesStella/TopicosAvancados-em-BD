DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- SEÇÃO 1: ATORES DA PLATAFORMA
CREATE TABLE Usuarios (
    usuario_id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL
);

CREATE TABLE Enderecos (
    endereco_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES Usuarios(usuario_id),
    cep VARCHAR(9) NOT NULL,
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(20),
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL
);

CREATE TABLE Lojas (
    loja_id SERIAL PRIMARY KEY,
    usuario_dono_id INT NOT NULL REFERENCES Usuarios(usuario_id),
    nome_loja VARCHAR(255) NOT NULL UNIQUE
);

-- SEÇÃO 2: VITRINE E PRODUTOS
CREATE TABLE Categorias (
    categoria_id SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Produtos (
    produto_id SERIAL PRIMARY KEY,
    loja_id INT NOT NULL REFERENCES Lojas(loja_id),
    categoria_id INT NOT NULL REFERENCES Categorias(categoria_id),
    fornecedor_id INT,
    nome_produto VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL -- O CHECK foi removido para o TRIGGER ser o único validador
);

-- SEÇÃO 3: LOGÍSTICA (Mantido)
CREATE TABLE Armazens (
    armazem_id SERIAL PRIMARY KEY,
    nome_armazem VARCHAR(255) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL
);

CREATE TABLE Transportadoras (
    transportadora_id SERIAL PRIMARY KEY,
    nome_transportadora VARCHAR(100) NOT NULL UNIQUE
);

-- SEÇÃO 4: COMPRA E ENTREGA (Mantido)
CREATE TABLE Pedidos (
    pedido_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES Usuarios(usuario_id),
    endereco_entrega_id INT NOT NULL REFERENCES Enderecos(endereco_id),
    data_pedido TIMESTAMPTZ DEFAULT (now() at time zone 'America/Sao_Paulo'),
    status_pedido VARCHAR(50) DEFAULT 'Criado'
);

CREATE TABLE Itens_Pedido (
    item_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL REFERENCES Pedidos(pedido_id),
    produto_id INT NOT NULL REFERENCES Produtos(produto_id),
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_no_momento_da_compra DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Envios (
    envio_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL UNIQUE REFERENCES Pedidos(pedido_id),
    transportadora_id INT NOT NULL REFERENCES Transportadoras(transportadora_id),
    armazem_origem_id INT NOT NULL REFERENCES Armazens(armazem_id),
    codigo_rastreio VARCHAR(100)
);

CREATE TABLE Status_Envio (
    status_id SERIAL PRIMARY KEY,
    envio_id INT NOT NULL REFERENCES Envios(envio_id),
    status_descricao VARCHAR(255) NOT NULL,
    data_status TIMESTAMPTZ DEFAULT (now() at time zone 'America/Sao_Paulo'),
    localizacao VARCHAR(255)
);

-- SEÇÃO 5: O objetivo principal desse trigger é garantir a integridade dos dados,
-- impedindo que um produto seja cadastrado ou atualizado com um preço zero ou negativo.

-- PARTE 1: Função
-- o que fazer? Essa funçãop CONTÉM A REGRA DE NEGÓCIO.
-- ELA VERIFICA SE O PREÇO É VÁLIDO. SE FOR INVÁLIDO, ELA BLOQUEIA A OPERAÇÃO
-- DISPARANDO UM ERRO de "raise exeption"
CREATE OR REPLACE FUNCTION fn_validar_preco_positivo()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o novo preço é menor ou igual a zero
    IF NEW.preco <= 0 THEN
        -- Se for, dispara uma exceção e cancela a operação
        -- obs: está com '%' para formatação correta na saida do terminal
        RAISE EXCEPTION 'O preço do produto (R$ %) deve ser maior que zero.', NEW.preco;
    END IF;
    
    -- Se o preço estiver OK, permite que a operação (INSERT ou UPDATE) continue
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- PARTE 2: O TRIGGER 
-- QUANDO A LÓGICA ACIMA DEVE SER EXECUTADA.
CREATE TRIGGER trg_validar_preco_produto
BEFORE INSERT OR UPDATE ON Produtos
FOR EACH ROW
EXECUTE FUNCTION fn_validar_preco_positivo();