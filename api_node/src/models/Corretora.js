import { DataTypes } from "sequelize";
import sequelize from "../config/database.js";

export const Corretora = sequelize.define(
  "Corretora",
  {
    nome: { type: DataTypes.STRING, allowNull: false },
    cnpj: DataTypes.STRING,
    taxa_corretagem: DataTypes.DECIMAL(10, 2),
    usuario_id: { type: DataTypes.INTEGER, allowNull: false },
    saldo: {
      type: DataTypes.DECIMAL(14, 2),
      allowNull: false,
      defaultValue: 0,
    },
  },
  { 
    tableName: "corretoras", 
    underscored: true,
    timestamps: false, // adicione esta linha
  }
);

export default Corretora;
