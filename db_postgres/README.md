Instruções rápidas (Windows)
1. Instale PostgreSQL (ex: via installer official).
2. Abra o pgAdmin ou psql.
3. Crie o banco 'bolsa_db' (ou altere DB_NAME no .env).
4. No PowerShell rode:
   psql -U postgres -d bolsa_db -f init.sql
