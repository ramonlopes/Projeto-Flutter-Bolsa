import { Router } from 'express';
import { Transacao, Usuario, Acao } from '../models/index.js';

const router = Router();

// Listar todas as transações (com join de usuário e ação)
router.get('/', async (req, res, next) => {
  try {
    const lista = await Transacao.findAll({
      include: [
        { model: Usuario, attributes: ['id', 'nome', 'email'] },
        { model: Acao, attributes: ['id', 'codigo', 'nome_empresa'] },
      ],
      order: [['data_transacao', 'DESC']],
    });
    res.status(200).json(lista);
  } catch (e) {
    next(e);
  }
});

// Buscar transações de um usuário
router.get('/usuario/:usuario_id', async (req, res, next) => {
  try {
    const lista = await Transacao.findAll({
      where: { usuario_id: req.params.usuario_id },
      include: [{ model: Acao, attributes: ['id', 'codigo', 'nome_empresa'] }],
      order: [['data_transacao', 'DESC']],
    });
    res.status(200).json(lista);
  } catch (e) {
    next(e);
  }
});

// Criar transação
router.post('/', async (req, res, next) => {
  try {
    const { usuario_id, acao_id, tipo, quantidade, preco_unitario } = req.body;
    if (!usuario_id || !acao_id || !tipo || !quantidade || !preco_unitario) {
      return res.status(400).json({ error: 'Campos obrigatórios faltando' });
    }
    const criada = await Transacao.create({
      usuario_id,
      acao_id,
      tipo,
      quantidade,
      preco_unitario,
    });
    res.status(201).json(criada);
  } catch (e) {
    next(e);
  }
});

// Seed
router.post('/seed', async (req, res, next) => {
  try {
    const count = await Transacao.count();
    if (count > 0) return res.json({ msg: 'Já existem transações' });
    await Transacao.bulkCreate([
      {
        usuario_id: 1,
        acao_id: 1,
        tipo: 'compra',
        quantidade: 100,
        preco_unitario: 37.20,
      },
      {
        usuario_id: 1,
        acao_id: 2,
        tipo: 'venda',
        quantidade: 50,
        preco_unitario: 61.80,
      },
    ]);
    res.status(201).json({ msg: 'Seed transações criado' });
  } catch (e) {
    next(e);
  }
});

// Atualizar transação
router.put('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { usuario_id, acao_id, tipo, quantidade, preco_unitario } = req.body;
    
    const transacao = await Transacao.findByPk(id);
    if (!transacao) {
      return res.status(404).json({ error: 'Transação não encontrada' });
    }

    await transacao.update({
      usuario_id: usuario_id ?? transacao.usuario_id,
      acao_id: acao_id ?? transacao.acao_id,
      tipo: tipo ?? transacao.tipo,
      quantidade: quantidade ?? transacao.quantidade,
      preco_unitario: preco_unitario ?? transacao.preco_unitario,
    });

    res.status(200).json(transacao);
  } catch (e) {
    next(e);
  }
});

// Deletar transação
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const transacao = await Transacao.findByPk(id);
    if (!transacao) {
      return res.status(404).json({ error: 'Transação não encontrada' });
    }
    await transacao.destroy();
    res.status(204).send();
  } catch (e) {
    next(e);
  }
});

export default router;