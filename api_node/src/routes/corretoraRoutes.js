import express from 'express';
import { Corretora } from '../models/Corretora.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

router.get('/', authMiddleware, async (req,res)=>{
  const lista = await Corretora.findAll({
    where: { usuario_id: req.usuarioId },
    order: [['nome','ASC']],
  });
  res.json(lista);
});

router.post('/', authMiddleware, async (req,res)=>{
  const { nome, cnpj, taxa_corretagem } = req.body;
  const c = await Corretora.create({ nome, cnpj, taxa_corretagem, usuario_id: req.usuarioId });
  res.status(201).json(c);
});

router.put('/:id', authMiddleware, async (req,res)=>{
  const { id } = req.params;
  const c = await Corretora.findOne({ where: { id, usuario_id: req.usuarioId } });
  if (!c) return res.status(404).json({ error: 'Corretora não encontrada' });
  const { nome, cnpj, taxa_corretagem } = req.body;
  await c.update({ nome, cnpj, taxa_corretagem });
  res.json(c);
});

router.delete('/:id', authMiddleware, async (req,res)=>{
  const { id } = req.params;
  const c = await Corretora.findOne({ where: { id, usuario_id: req.usuarioId } });
  if (!c) return res.status(404).json({ error: 'Corretora não encontrada' });
  await c.destroy();
  res.status(204).send();
});

export default router;