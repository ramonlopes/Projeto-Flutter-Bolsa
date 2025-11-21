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

export default router;
