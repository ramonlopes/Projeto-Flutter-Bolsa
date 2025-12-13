import Usuario from './Usuario.js';
import Acao from './Acao.js';
import Transacao from './Transacao.js';

// Relacionamentos
Usuario.hasMany(Transacao, { foreignKey: 'usuario_id' });
Transacao.belongsTo(Usuario, { foreignKey: 'usuario_id' });

Acao.hasMany(Transacao, { foreignKey: 'acao_id' });
Transacao.belongsTo(Acao, { foreignKey: 'acao_id' });

export { Usuario, Acao, Transacao };