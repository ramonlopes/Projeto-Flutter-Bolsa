import { Router } from 'express';
import Acao from '../models/Acao.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const lista = await Acao.findAll({ order: [['id','ASC']] });
    res.status(200).json(lista);
  } catch (e) { next(e); }
});

router.post('/seed', async (req, res, next) => {
  try {
    const count = await Acao.count();
    if (count > 0) return res.json({ msg: 'Já existe conteúdo' });
    await Acao.bulkCreate([
      { codigo: 'PETR4', nome_empresa: 'Petrobras PN', preco_atual: 37.20 },
      { codigo: 'VALE3', nome_empresa: 'Vale ON', preco_atual: 61.80 }
    ]);
    res.status(201).json({ msg: 'Seed criado' });
  } catch (e) { next(e); }
});

// Preço em tempo (Yahoo Finance) com fetch nativo
router.get('/preco/:codigo', async (req, res, next) => {
  try {
    const raw = req.params.codigo.trim();
    const simbolo = raw.endsWith('.SA') ? raw : `${raw}.SA`;
    const url = `https://query1.finance.yahoo.com/v7/finance/quote?symbols=${encodeURIComponent(simbolo)}`;

    const resp = await fetch(url, { method: 'GET' });
    if (!resp.ok) return res.status(502).json({ error: 'Falha ao consultar Yahoo' });
    const data = await resp.json();

    const result = data?.quoteResponse?.result?.[0];
    if (!result) return res.status(404).json({ error: 'Código não encontrado' });

    const preco = result.regularMarketPrice;
    const variacao = result.regularMarketChangePercent;
    const moeda = result.currency || 'BRL';
    const ts = result.regularMarketTime ? new Date(result.regularMarketTime * 1000).toISOString() : new Date().toISOString();

    res.json({
      codigo: raw,
      simboloYahoo: simbolo,
      preco,
      variacaoPercent: variacao,
      moeda,
      atualizadoEm: ts,
      fonte: 'Yahoo Finance',
    });
  } catch (e) { next(e); }
});

// Criar ação
router.post('/', async (req, res, next) => {
  try {
    const { codigo, nome_empresa, preco_atual } = req.body;
    if (!codigo || !nome_empresa || !preco_atual) {
      return res.status(400).json({ error: 'Campos obrigatórios faltando' });
    }
    const criada = await Acao.create({ codigo, nome_empresa, preco_atual });
    res.status(201).json(criada);
  } catch (e) { next(e); }
});

// Atualizar ação
router.put('/:id', async (req, res, next) => {
  try {
    const acao = await Acao.findByPk(req.params.id);
    if (!acao) return res.status(404).json({ error: 'Ação não encontrada' });
    const { codigo, nome_empresa, preco_atual } = req.body;
    await acao.update({ codigo, nome_empresa, preco_atual });
    res.status(200).json(acao);
  } catch (e) { next(e); }
});

// Deletar ação
router.delete('/:id', async (req, res, next) => {
  try {
    const acao = await Acao.findByPk(req.params.id);
    if (!acao) return res.status(404).json({ error: 'Ação não encontrada' });
    await acao.destroy();
    res.status(204).send();
  } catch (e) { next(e); }
});

export default router;
