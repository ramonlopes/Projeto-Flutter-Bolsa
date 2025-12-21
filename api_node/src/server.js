import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import sequelize from './config/database.js';
import './models/index.js'; // carrega relacionamentos ANTES do sync
import app from './app.js';
import yahooRoutes from './routes/yahoo.js'; // ADICIONE

dotenv.config();

const start = async () => {
  try {
    await sequelize.authenticate();
    console.log('Conectado ao Postgres.');
    await sequelize.sync(); // sem force/alter
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Servidor rodando em http://localhost:${PORT}`);
    });
    // app.listen(PORT, '192.168.10.18', () => {
    //   console.log(`Servidor rodando em http://192.168.10.18:${PORT}`);
    // });    
  } catch (e) {
    console.error('Erro ao iniciar servidor:', e);
    process.exit(1);
  }
};

start();

app.use('/yahoo', yahooRoutes); // ADICIONE antes do error handler

export { app }; // permite import em testes, se necessário
