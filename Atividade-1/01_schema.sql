-- Script para criar todas as tabelas, chaves e relacionamentos do banco de dados.

-- (útil para testes) Reseta o schema 'public' para garantir um ambiente limpo.
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- SEÇÃO 1: ATORES DA PLATAFORMA

CREATE TABLE Usuarios (
    usuario_id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    data_cadastro TIMESTAMPTZ DEFAULT (now() at time zone 'America/Sao_Paulo')
);

CREATE TABLE Enderecos (
    endereco_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES Usuarios(usuario_id),
    cep VARCHAR(9) NOT NULL,
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(20),
    complemento VARCHAR(100),
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL
);

CREATE TABLE Lojas (
    loja_id SERIAL PRIMARY KEY,
    usuario_dono_id INT NOT NULL REFERENCES Usuarios(usuario_id),
    nome_loja VARCHAR(255) NOT NULL UNIQUE,
    descricao TEXT,
    data_criacao TIMESTAMPTZ DEFAULT (now() at time zone 'America/Sao_Paulo')
);


-- SEÇÃO 2: VITRINE E PRODUTOS

CREATE TABLE Categorias (
    categoria_id SERIAL PRIMARY KEY,
    nome_categoria VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Fornecedores (
    fornecedor_id SERIAL PRIMARY KEY,
    loja_id INT NOT NULL REFERENCES Lojas(loja_id),
    nome_fornecedor VARCHAR(255) NOT NULL,
    contato_email VARCHAR(255)
);

CREATE TABLE Produtos (
    produto_id SERIAL PRIMARY KEY,
    loja_id INT NOT NULL REFERENCES Lojas(loja_id),
    categoria_id INT NOT NULL REFERENCES Categorias(categoria_id),
    fornecedor_id INT REFERENCES Fornecedores(fornecedor_id),
    nome_produto VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL CHECK (preco > 0)
);


-- SEÇÃO 3: LOGÍSTICA

CREATE TABLE Armazens (
    armazem_id SERIAL PRIMARY KEY,
    nome_armazem VARCHAR(255) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL
);

-- Tabela de junção para controlar o estoque de produtos em cada armazém (N-para-N)
CREATE TABLE Inventario (
    produto_id INT NOT NULL REFERENCES Produtos(produto_id),
    armazem_id INT NOT NULL REFERENCES Armazens(armazem_id),
    quantidade_disponivel INT NOT NULL CHECK (quantidade_disponivel >= 0),
    PRIMARY KEY (produto_id, armazem_id) -- Chave primária composta
);

CREATE TABLE Transportadoras (
    transportadora_id SERIAL PRIMARY KEY,
    nome_transportadora VARCHAR(100) NOT NULL UNIQUE
);

-- SEÇÃO 4: COMPRA E ENTREGA

CREATE TABLE Pedidos (
    pedido_id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES Usuarios(usuario_id),
    endereco_entrega_id INT NOT NULL REFERENCES Enderecos(endereco_id),
    data_pedido TIMESTAMPTZ DEFAULT (now() at time zone 'America/Sao_Paulo'),
    status_pedido VARCHAR(50) DEFAULT 'Criado'
);

-- Tabela de junção que representa os itens de um pedido (N-para-N)
CREATE TABLE Itens_Pedido (
    item_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL REFERENCES Pedidos(pedido_id),
    produto_id INT NOT NULL REFERENCES Produtos(produto_id),
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_no_momento_da_compra DECIMAL(10, 2) NOT NULL -- Guarda o preço histórico
);

CREATE TABLE Envios (
    envio_id SERIAL PRIMARY KEY,
    pedido_id INT NOT NULL UNIQUE REFERENCES Pedidos(pedido_id), -- Garante a relação 1-para-1
    transportadora_id INT NOT NULL REFERENCES Transportadoras(transportadora_id),
    armazem_origem_id INT NOT NULL REFERENCES Armazens(armazem_id),
    codigo_rastreio VARCHAR(100),
    data_envio TIMESTAMPTZ,
    previsao_entrega DATE
);

CREATE TABLE Status_Envio (
    status_id SERIAL PRIMARY KEY,
    envio_id INT NOT NULL REFERENCES Envios(envio_id),
    status_descricao VARCHAR(255) NOT NULL,
    data_status TIMESTAMPTZ DEFAULT (now() at time zone 'America/Sao_Paulo'),
    localizacao VARCHAR(255)
);