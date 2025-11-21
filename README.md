Projeto exemplo: Flutter + Node.js + PostgreSQL (Windows target, Sequelize)

Estrutura:
- api_node/: Backend Node.js + Express + Sequelize
- db_postgres/: scripts SQL para criar tabelas
- app_flutter/: App Flutter que consome a API

Passos iniciais (Windows):
1) Instale PostgreSQL e crie o banco 'bolsa_db' ou altere DB_NAME no api_node/.env
2) No PowerShell, rode (na pasta db_postgres):
   psql -U postgres -d bolsa_db -f init.sql
3) Backend:
   cd api_node
   npm install
   REM ajuste .env com a senha do Postgres
   npm run dev
4) App Flutter:
   cd app_flutter
   flutter pub get
   flutter run

Observações:
- O app usa 10.0.2.2 para o emulador Android no Windows. Se testar em dispositivo físico, troque para o IP da máquina.
- Senhas/personalizações: altere o arquivo api_node/.env antes de rodar.
