import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";

const Acao = sequelize.define("Acao", {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  codigo: { type: DataTypes.STRING(10), allowNull: false },
  nome_empresa: { type: DataTypes.STRING(100), allowNull: false },
  preco_atual: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
}, {
  tableName: "acoes",
  timestamps: false,
  freezeTableName: true,
});

export default Acao;
