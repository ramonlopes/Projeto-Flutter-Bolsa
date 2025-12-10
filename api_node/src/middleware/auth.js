import jwt from 'jsonwebtoken';

export function authMiddleware(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth?.startsWith('Bearer ')) return res.status(401).json({ error: 'Token ausente' });
  try {
    const token = auth.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_dev');
    req.usuarioId = decoded.id;
    next();
  } catch {
    return res.status(401).json({ error: 'Token inválido' });
  }
}