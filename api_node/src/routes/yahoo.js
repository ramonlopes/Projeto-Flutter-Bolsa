import express from 'express';
import axios from 'axios';

const router = express.Router();

// GET /yahoo/cotacao/:simbolo
router.get('/cotacao/:simbolo', async (req, res, next) => {
  try {
    const { simbolo } = req.params;
    const url = `https://query1.finance.yahoo.com/v8/finance/chart/${simbolo}?interval=1d&range=1d`;
    
    let response;
    try {
      response = await axios.get(url, {
        timeout: 5000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
      });
    } catch (axiosError) {
      console.error(`Erro ao buscar ${simbolo} do Yahoo:`, axiosError.code || axiosError.message);
      return res.status(503).json({ error: 'Serviço indisponível temporariamente' });
    }

    const result = response.data?.chart?.result?.[0];
    if (!result) {
      return res.status(404).json({ error: 'Cotação não encontrada' });
    }

    const meta = result.meta;
    res.json({
      simbolo: meta?.symbol || simbolo,
      preco: meta?.regularMarketPrice || null,
      variacaoPercent: meta?.regularMarketChangePercent || null,
      moeda: meta?.currency || 'BRL',
      atualizadoEm: new Date((meta?.regularMarketTime || 0) * 1000).toISOString(),
    });
  } catch (error) {
    console.error('Erro inesperado em /cotacao/:simbolo:', error.message);
    if (!res.headersSent) {
      res.status(500).json({ error: 'Erro ao buscar cotação' });
    }
  }
});

// POST /yahoo/cotacoes
router.post('/cotacoes', async (req, res, next) => {
  try {
    const { simbolos } = req.body;
    
    if (!Array.isArray(simbolos) || simbolos.length === 0) {
      return res.status(400).json({ error: 'Envie array de símbolos' });
    }

    const promises = simbolos.map(async (simbolo) => {
      try {
        const url = `https://query1.finance.yahoo.com/v8/finance/chart/${simbolo}?interval=1d&range=1d`;
        let response;
        try {
          response = await axios.get(url, {
            timeout: 5000,
            headers: { 'User-Agent': 'Mozilla/5.0' }
          });
        } catch (axiosError) {
          console.warn(`Falha ao buscar ${simbolo}:`, axiosError.code || axiosError.message);
          return { simbolo, preco: null, variacaoPercent: null };
        }
        
        const meta = response.data?.chart?.result?.[0]?.meta;
        return {
          simbolo,
          preco: meta?.regularMarketPrice || null,
          variacaoPercent: meta?.regularMarketChangePercent || null,
        };
      } catch (err) {
        console.warn(`Erro ao processar ${simbolo}:`, err.message);
        return { simbolo, preco: null, variacaoPercent: null };
      }
    });

    const resultados = await Promise.all(promises);
    res.json(resultados);
  } catch (error) {
    console.error('Erro ao buscar cotações:', error.message);
    if (!res.headersSent) {
      res.status(500).json({ error: 'Erro ao buscar cotações' });
    }
  }
});

export default router;