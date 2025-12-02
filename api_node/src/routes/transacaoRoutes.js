import { Router } from 'express';
import { Transacao, Usuario, Acao } from '../models/index.js';
import { authMiddleware } from '../middleware/auth.js';

const router = Router();

// Listar (apenas do usuário logado)
router.get('/', authMiddleware, async (req, res, next) => {
  try {
    const lista = await Transacao.findAll({
      where: { usuario_id: req.usuarioId },
      include: [
        { model: Usuario, attributes: ['id','nome','email'] },
        { model: Acao, attributes: ['id','codigo','nome_empresa'] },
      ],
      order: [['data_transacao','DESC']],
    });
    res.json(lista);
  } catch (e) { next(e); }
});

// Criar (força usuario_id do token)
router.post('/', authMiddleware, async (req, res, next) => {
  try {
    const dados = { ...req.body, usuario_id: req.usuarioId };
    const criada = await Transacao.create(dados);
    res.status(201).json(criada);
  } catch (e) { next(e); }
});

// Atualizar (somente se dono)
router.put('/:id', authMiddleware, async (req, res, next) => {
  try {
    const t = await Transacao.findOne({ where: { id: req.params.id, usuario_id: req.usuarioId } });
    if (!t) return res.status(404).json({ error: 'Transação não encontrada' });
    await t.update({ ...req.body, usuario_id: req.usuarioId });
    res.json(t);
  } catch (e) { next(e); }
});

// Deletar (somente se dono)
router.delete('/:id', authMiddleware, async (req, res, next) => {
  try {
    const t = await Transacao.findOne({ where: { id: req.params.id, usuario_id: req.usuarioId } });
    if (!t) return res.status(404).json({ error: 'Transação não encontrada' });
    await t.destroy();
    res.status(204).send();
  } catch (e) { next(e); }
});

export default router;