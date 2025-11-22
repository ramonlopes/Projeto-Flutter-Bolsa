import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

import sequelize from './config/database.js';
import usuarioRoutes from './routes/usuarioRoutes.js';
import acaoRoutes from './routes/acaoRoutes.js';

dotenv.config();

const app = express();

// Logs simples
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} Origin=${req.headers.origin || '-'}`);
  next();
});

// CORS para localhost
app.use(cors({
  origin: (origin, cb) => {
    if (!origin) return cb(null, true);
    if (origin.startsWith('http://localhost') || origin.startsWith('http://127.0.0.1')) return cb(null, true);
    return cb(new Error('Origem não permitida'));
  },
  methods: ['GET','POST','PUT','DELETE','OPTIONS'],
  allowedHeaders: ['Content-Type','Authorization','Accept'],
  credentials: false,
  maxAge: 86400
}));
app.options('*', cors());

app.use(express.json());

// Healthcheck
app.get('/healthz', (req, res) => res.status(200).json({ ok: true }));

// Rotas
app.use('/usuarios', usuarioRoutes);
app.use('/acoes', acaoRoutes);

// 404
app.use((req, res) => res.status(404).json({ error: 'Rota não encontrada' }));

// Handler de erro
app.use((err, req, res, next) => {
  console.error('Erro:', err);
  res.status(500).json({ error: err.message || 'Erro interno' });
});

// Start
const start = async () => {
  try {
    await sequelize.authenticate();
    console.log('Conectado ao Postgres.');
    await sequelize.sync(); // sem force/alter
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
