import express from "express";
import cors from "cors";
import dotenv from "dotenv";
dotenv.config();

import sequelize from "./config/database.js";
import usuarioRoutes from "./routes/usuarioRoutes.js";
import acaoRoutes from "./routes/acaoRoutes.js";

const app = express();

// Logs simples p/ debug
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} Origin=${req.headers.origin || '-'}`);
  next();
});

// CORS (permite localhost e pré-flight)
app.use(cors({
  origin: (origin, cb) => {
    if (!origin) return cb(null, true);
    if (origin.startsWith('http://localhost') || origin.startsWith('http://127.0.0.1')) return cb(null, true);
    return cb(new Error('Origem não permitida'));
  },
  methods: ['GET','POST','PUT','DELETE','OPTIONS'],
  allowedHeaders: ['Content-Type','Authorization','Accept'], // inclui Accept
  maxAge: 86400
}));
app.options('*', cors());

app.use(express.json());

// Healthcheck
app.get('/healthz', (req, res) => res.status(200).json({ ok: true }));

app.use("/usuarios", usuarioRoutes);
app.use("/acoes", acaoRoutes);

// 404 e errors
app.use((req, res) => res.status(404).json({ error: 'Rota não encontrada' }));
app.use((err, req, res, next) => {
  console.error('Erro:', err);
  res.status(500).json({ error: err.message || 'Erro interno' });
});

console.log('ENV DB=', process.env.POSTGRES_DB);
console.log('ENV USER=', process.env.POSTGRES_USER);
console.log('ENV PASS typeof=', typeof process.env.POSTGRES_PASSWORD);

const start = async () => {
  try {
    await sequelize.authenticate();
    console.log("Conectado ao Postgres com sucesso.");
    await sequelize.sync(); // certifique-se que não há { force: true } ou { alter: true }
    console.log("Modelos sincronizados.");
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, '0.0.0.0', () =>
      console.log(`Servidor rodando em http://localhost:${PORT}`)
    );
  } catch (err) {
    console.error("Erro ao iniciar servidor:", err);
    process.exit(1);
  }
};

start();
