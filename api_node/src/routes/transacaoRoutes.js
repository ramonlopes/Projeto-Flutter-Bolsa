import { Router } from 'express';
import { Transacao, Usuario, Acao } from '../models/index.js';
import { authMiddleware } from '../middleware/auth.js';

const router = Router();

// Listar apenas transações do usuário logado
router.get('/', authMiddleware, async (req, res, next) => {
  try {
    const lista = await Transacao.findAll({
      where: { usuario_id: req.usuarioId },
      include: [
        { model: Usuario, attributes: ['id', 'nome', 'email'] },
        { model: Acao, attributes: ['id', 'codigo', 'nome_empresa'] }
      ],
      order: [['data_transacao', 'DESC']]
    });
    res.status(200).json(lista);
  } catch (e) { next(e); }
});

// Criar transação (força usuario_id = usuário logado)
router.post('/', authMiddleware, async (req, res, next) => {
  try {
    const {
      acao_id, tipo, quantidade, preco_unitario,
      tipo_operacao, nome_opcao, valor_mercado, valor_strike,
      data_exercicio, porcentagem_premio, valor_premio_liquido,
      percentual_retorno, percentual_retorno_liquido, situacao_momento,
      valor_cobertural, exercido_operacao, corretora_operada, valor_irrf,
    } = req.body;

    if (!acao_id || !tipo || !quantidade || !preco_unitario) {
      return res.status(400).json({ error: 'Campos obrigatórios faltando' });
    }

    const criada = await Transacao.create({
      usuario_id: req.usuarioId, // força ID do usuário logado
      acao_id, tipo, quantidade, preco_unitario,
      tipo_operacao, nome_opcao, valor_mercado, valor_strike,
      data_exercicio, porcentagem_premio, valor_premio_liquido,
      percentual_retorno, percentual_retorno_liquido, situacao_momento,
      valor_cobertural, exercido_operacao, corretora_operada, valor_irrf,
    });
    res.status(201).json(criada);
  } catch (e) { next(e); }
});

// Atualizar (apenas se for do usuário logado)
router.put('/:id', authMiddleware, async (req, res, next) => {
  try {
    const t = await Transacao.findOne({
      where: { id: req.params.id, usuario_id: req.usuarioId }
    });
    if (!t) return res.status(404).json({ error: 'Transação não encontrada' });
    await t.update({ ...req.body, usuario_id: req.usuarioId }); // mantém usuario_id
    res.status(200).json(t);
  } catch (e) { next(e); }
});

// Deletar (apenas se for do usuário logado)
router.delete('/:id', authMiddleware, async (req, res, next) => {
  try {
    const t = await Transacao.findOne({
      where: { id: req.params.id, usuario_id: req.usuarioId }
    });
    if (!t) return res.status(404).json({ error: 'Transação não encontrada' });
    await t.destroy();
    res.status(204).send();
  } catch (e) { next(e); }
});

export default router;