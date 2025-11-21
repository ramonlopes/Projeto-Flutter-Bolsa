import { Router } from 'express';
import Usuario from '../models/Usuario.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const lista = await Usuario.findAll({
      attributes: ['id','nome','email'],
      order: [['id','ASC']]
    });
    console.log('GET /usuarios count=', lista.length);
    res.status(200).json(lista);
  } catch (e) { next(e); }
});

router.post('/', async (req, res, next) => {
  try {
    const { nome, email, senha } = req.body;
    if (!nome || !email || !senha) {
      return res.status(400).json({ error: 'Campos obrigatórios' });
    }
    const criado = await Usuario.create({ nome, email, senha });
    console.log('POST /usuarios criado id=', criado.id);
    res.status(201).json({ id: criado.id, nome: criado.nome, email: criado.email });
  } catch (e) {
    console.error('Erro POST /usuarios', e);
    next(e);
  }
});

export default router;
