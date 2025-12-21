import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";

export const Acao = sequelize.define(
  "Acao",
  {
    codigo: { type: DataTypes.STRING, allowNull: false, unique: true },
    nomeEmpresa: { type: DataTypes.STRING, allowNull: false },
    precoAtual: DataTypes.DECIMAL(14, 2),
    precoMedio: DataTypes.DECIMAL(14, 2),
    usuarioId: { type: DataTypes.INTEGER, allowNull: false },
  },
  {
    tableName: "acoes",
    underscored: true,
    timestamps: false, // adicione esta linha
  }
);

export default Acao;
