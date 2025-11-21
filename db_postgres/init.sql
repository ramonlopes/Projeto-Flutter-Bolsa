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
