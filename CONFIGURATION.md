# Configuração do Projeto

Este arquivo descreve as variáveis e passos para configurar o projeto localmente.

## Variáveis de ambiente
Crie um arquivo `.env` na raiz com base em `.env.example`:
- API_BASE_URL: URL da API de cotações
- API_KEY: chave da API
- ENABLE_MOCK: true/false para usar dados mock

## Plugins / Ferramentas recomendadas
- flutter_dotenv (para carregar .env)
- hive (cache local)
- dio (requisições HTTP)
- flutter_local_notifications (notificações)

## Integração com APIs
- Descreva endpoints principais e formatos (ex: /quotes/:symbol, /news)

## Modo mock
- Para desenvolvimento sem API, ative `ENABLE_MOCK=true` e verifique `lib/src/core/mocks/`.
