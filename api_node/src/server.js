import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import sequelize from './config/database.js';
import app from './app.js';

dotenv.config();

const start = async () => {
  try {
    await sequelize.authenticate();
    console.log('Conectado ao Postgres.');
    await sequelize.sync();
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Servidor rodando em http://localhost:${PORT}`);
    });
  } catch (e) {
    console.error('Erro ao iniciar servidor:', e);
    process.exit(1);
  }
};

start();

export { app }; // permite import em testes, se necessário
