import express from 'express';
import cors from 'cors';
import usuarioRoutes from './routes/usuarioRoutes.js';
import acaoRoutes from './routes/acaoRoutes.js';

export function createApp() {
  const app = express();

  app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} Origin=${req.headers.origin || '-'}`);
    next();
  });

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

  app.get('/healthz', (req, res) => res.status(200).json({ ok: true }));

  app.use('/usuarios', usuarioRoutes);
  app.use('/acoes', acaoRoutes);

  app.use((req, res) => res.status(404).json({ error: 'Rota não encontrada' }));

  app.use((err, req, res, next) => {
    console.error('Erro:', err);
    res.status(500).json({ error: err.message || 'Erro interno' });
  });

  return app;
}

export default createApp();