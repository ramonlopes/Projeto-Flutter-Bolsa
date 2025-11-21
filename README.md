# Bolsa de Valores (Flutter + Node + Postgres)

## Estrutura
- api_node: Backend Node.js (Express, Sequelize, Postgres)
- app_flutter: Frontend Flutter (Web/Chrome e mobile)
- db_postgres: Script init.sql (tabelas)

## Requisitos
- Node >= 18
- PostgreSQL >= 13
- Flutter SDK >= 3.x
- Git

## Banco de Dados
Crie o banco e tabelas:
```sql
CREATE DATABASE bolsa_db;
\c bolsa_db
-- usar db_postgres/init.sql
```

## .env (não commitar)
Crie em api_node/.env:
```
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=bolsa_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=SUA_SENHA
PORT=3000
```

## Backend
```bash
cd api_node
npm install
node src/server.js
# Testar
curl http://localhost:3000/healthz
curl -X POST http://localhost:3000/acoes/seed
curl http://localhost:3000/acoes
curl -X POST http://localhost:3000/usuarios -H "Content-Type: application/json" -d "{\"nome\":\"Alice\",\"email\":\"alice@mail.com\",\"senha\":\"123\"}"
curl http://localhost:3000/usuarios
```

## Frontend
Editar lib/config/api_config.dart se porta/host mudar.
```bash
cd app_flutter
flutter pub get
flutter run -d chrome
```

## Estrutura principal Flutter
- models/Acao, Usuario
- services/acao_service.dart, usuario_service.dart
- screens/acoes_screen.dart, usuarios_screen.dart

## Scripts úteis
Adicionar no package.json (api_node):
```json
"scripts": {
  "dev": "node src/server.js"
}
```

## Commit padrão
- feat: nova funcionalidade
- fix: correção
- docs: atualização README
- chore: manutenção

## Próximos passos
- Autenticação JWT
- Validação de entrada
- Testes automatizados

## Licença
Definir (ex: MIT).
[![CI](https://github.com/SEU_USUARIO/Projeto-Flutter-Bolsa/actions/workflows/ci.yml/badge.svg)](https://github.com/SEU_USUARIO/Projeto-Flutter-Bolsa/actions/workflows/ci.yml)
