import Acao from "../models/Acao.js";

export const listarAcoes = async (req, res) => {
  try {
    const acoes = await Acao.findAll();
    res.json(acoes);
  } catch (err) {
    res.status(500).json({ erro: err.message });
  }
};

export const criarAcao = async (req, res) => {
  try {
    const acao = await Acao.create(req.body);
    res.status(201).json(acao);
  } catch (err) {
    res.status(400).json({ erro: err.message });
  }
};
