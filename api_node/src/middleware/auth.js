import jwt from 'jsonwebtoken';

export function authMiddleware(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth || !auth.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token ausente' });
  }
  const token = auth.substring(7);
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_dev');
    req.usuarioId = decoded.id; // injeta ID do usuário na request
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Token inválido' });
  }
}