# Etapa 1: Build do frontend
FROM node:20 AS etapa-build

# WORKDIR /app

# Copie apenas os arquivos necessários para instalar dependências e buildar
# COPY frontend/package*.json ./frontend/
# WORKDIR /app/frontend
# RUN npm ci

# Copie o restante do código do frontend e faça o build
# COPY frontend/ ./
# ENV VITE_APP_URL_API=api
# RUN npm run build

WORKDIR /app

COPY api_node/package*.json ./api_node/
WORKDIR /app/api_node
RUN npm ci --only=production

# Copie o restante do código do backend
COPY api_node/ ./

# Etapa 2: Servir com Nginx
FROM nginx:1.25-alpine AS production

# Instale o supervisor e nodejs
RUN apk add --no-cache nodejs supervisor postgresql postgresql-contrib

RUN mkdir -p /run/postgresql &&\
    chown postgres:postgres /run/postgresql

# Crie o diretório de dados do PostgreSQL   
COPY init-db.sh /docker-entrypoint-initdb.d/init-db.sh
RUN chown postgres:postgres /docker-entrypoint-initdb.d/init-db.sh && \
    chmod +x /docker-entrypoint-initdb.d/init-db.sh
COPY cargainicial.dmp /tmp/cargainicial.dmp
RUN chown postgres:postgres /tmp/cargainicial.dmp && \
    chmod 644 /tmp/cargainicial.dmp
# Inicialização do PostgreSQL
USER postgres
RUN /docker-entrypoint-initdb.d/init-db.sh

# Voltando para o usuário root para continuar a configuração do Nginx e do supervisor
USER root

# Remova a configuração padrão do Nginx
# RUN rm -rf /usr/share/nginx/html/*
# Copie o build do frontend para o diretório público do Nginx
# COPY --from=etapa-build /app/frontend/dist /usr/share/nginx/html

# Copie o api_node para a imagem final
COPY --from=etapa-build /app/api_node /app/api_node

# Copie o arquivo de configuração do supervisor
COPY supervisord.conf /etc/supervisord.conf

# Copie o arquivo de configuração customizado do nginx
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /app/api_node    

# Opcional: copie uma configuração customizada do nginx.conf se necessário
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
#CMD ["nginx", "-g", "daemon off;"]