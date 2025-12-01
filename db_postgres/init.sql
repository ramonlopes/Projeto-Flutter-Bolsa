-- Execute isso no psql (Windows PowerShell) ou use pgAdmin para criar o banco e as tabelas.
-- Exemplo usando psql (PowerShell):
-- psql -U postgres -f init.sql

-- cria banco (se desejar criar via script, remova o CREATE DATABASE se já criar via pgAdmin)
-- CREATE DATABASE bolsa_db;

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS usuarios (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  senha VARCHAR(100) NOT NULL
);

-- Tabela de ações
CREATE TABLE IF NOT EXISTS acoes (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(10) NOT NULL,
  nome_empresa VARCHAR(100) NOT NULL,
  preco_atual NUMERIC(10,2) NOT NULL
);

-- Tabela de transações
CREATE TABLE IF NOT EXISTS transacoes (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  acao_id INT NOT NULL REFERENCES acoes(id) ON DELETE CASCADE,
  tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('compra', 'venda')),
  quantidade INT NOT NULL CHECK (quantidade > 0),
  preco_unitario NUMERIC(10,2) NOT NULL,
  tipo_operacao VARCHAR(10) CHECK (tipo_operacao IN ('PUT', 'CALL')),
  nome_opcao VARCHAR(100),
  valor_mercado NUMERIC(10,2),
  valor_strike NUMERIC(10,2),
  data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_exercicio DATE,
  porcentagem_premio NUMERIC(7,4),
  valor_premio_liquido NUMERIC(10,2),
  percentual_retorno NUMERIC(7,4),
  percentual_retorno_liquido NUMERIC(7,4),
  situacao_momento NUMERIC(10,2),
  valor_cobertural NUMERIC(10,2),
  exercido_operacao BOOLEAN,
  corretora_operada VARCHAR(120),
  valor_irrf NUMERIC(10,2)
);
