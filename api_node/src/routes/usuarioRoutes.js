import { Router } from 'express';
import { verifyGoogleIdToken } from '../utils/googleVerify.js';
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

// Login com Google: recebe { idToken }
router.post('/google', async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ error: 'idToken é obrigatório' });

    const allowed = (process.env.GOOGLE_CLIENT_IDS || '').split(',').map(s => s.trim()).filter(Boolean);
    if (allowed.length === 0) return res.status(500).json({ error: 'GOOGLE_CLIENT_IDS não configurado' });

    const { email, name } = await verifyGoogleIdToken(idToken, allowed);

    // upsert usuário por e-mail (senha não usada para Google)
    let user = await Usuario.findOne({ where: { email } });
    if (!user) {
      user = await Usuario.create({ nome: name || email, email, senha: 'google-oauth' });
    }

    // Retorne dados essenciais (sem senha)
    return res.status(200).json({ id: user.id, nome: user.nome, email: user.email });
  } catch (e) {
    next(e);
  }
});

export default router;
