import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

export const Transacao = sequelize.define(
  'Transacao',
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    usuario_id: { type: DataTypes.INTEGER, allowNull: false },
    acao_id: { type: DataTypes.INTEGER, allowNull: false },
    tipo: {
      type: DataTypes.ENUM('compra', 'venda'),
      allowNull: false,
    },
    quantidade: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: { min: 1 },
    },
    preco_unitario: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    valor_operacao: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
    },
    tipo_operacao: {
      type: DataTypes.ENUM('PUT', 'CALL'),
      allowNull: true,
    },
    nome_opcao: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    valor_mercado: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    valor_strike: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    data_exercicio: {
      type: DataTypes.DATEONLY,
      allowNull: true,
    },
    porcentagem_premio: {
      // armazena percentual (ex.: 12.34)
      type: DataTypes.DECIMAL(7, 4),
      allowNull: true,
    },
    valor_premio_liquido: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    percentual_retorno: {
      type: DataTypes.DECIMAL(7, 4),
      allowNull: true,
    },
    percentual_retorno_liquido: {
      type: DataTypes.DECIMAL(7, 4),
      allowNull: true,
    },
    situacao_momento: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    valor_cobertural: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    exercido_operacao: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
    },
    corretora_operada: {
      type: DataTypes.STRING(120),
      allowNull: true,
    },
    valor_irrf: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true,
    },
    data_transacao: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    tableName: 'transacoes',
    underscored: true,
    timestamps: false, // adicione esta linha
  }
);

export default Transacao;