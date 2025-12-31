#!/bin/sh

set -e
DATADIR=/var/lib/postgresql/data

mkdir -p $DATADIR
chown postgres:postgres $DATADIR

initdb -D $DATADIR --auth-local peer --auth-host scram-sha-256 --no-instructions

# Inicia o PostgreSQL temporariamente para criar o banco de dados
pg_ctl start -D $DATADIR

# Aguarda o PostgreSQL iniciar
until pg_isready; do
  sleep 1
done

# Cria o banco de dados e usuário se necessário
psql -c "CREATE USER bolsa_user WITH PASSWORD 'bolsa';"
psql -c "CREATE DATABASE bolsa_db WITH OWNER postgres;"
psql -d bolsa_db -c "GRANT ALL PRIVILEGES ON DATABASE bolsa_db TO bolsa_user;"
pg_restore -d bolsa_db /tmp/cargainicial.dmp

#rodar comando de fazer grant all
# Grant all privileges on all tables to bolsa_user
psql -d bolsa_db -c "
DO \$\$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE 'GRANT ALL PRIVILEGES ON TABLE ' || quote_ident(r.tablename) || ' TO bolsa_user';
    END LOOP;
    
    FOR r IN 
        SELECT sequence_name FROM information_schema.sequences 
        WHERE sequence_schema = 'public'
    LOOP
        EXECUTE 'GRANT ALL PRIVILEGES ON SEQUENCE ' || quote_ident(r.sequence_name) || ' TO bolsa_user';
    END LOOP;
END
\$\$;
"
# Para o PostgreSQL (será reiniciado pelo supervisor)
pg_ctl stop -D $DATADIR