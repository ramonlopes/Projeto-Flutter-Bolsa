import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";

export const Corretora = sequelize.define(
  "Corretora",
  {
    nome: { type: DataTypes.STRING, allowNull: false },
    cnpj: DataTypes.STRING,
    taxa_corretagem: DataTypes.DECIMAL(10, 2),
    usuario_id: { type: DataTypes.INTEGER, allowNull: false },
  },
  { tableName: "corretoras", underscored: true }
);

export default Corretora;
