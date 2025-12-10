# Projeto Flutter Bolsa

Bem-vindo ao wiki do Projeto Flutter Bolsa — uma aplicação Flutter para gerenciar e visualizar cotações, notícias e carteira de ações/ativos. Esta página serve como ponto de partida para desenvolvedores e colaboradores: contém visão geral, como rodar localmente, arquitetura, práticas recomendadas e guia de contribuição.

---

## Índice
- [Visão Geral](#visão-geral)
- [Principais Funcionalidades](#principais-funcionalidades)
- [Screenshots](#screenshots)
- [Requisitos](#requisitos)
- [Instalação e Execução Rápida](#instalação-e-execução-rápida)
- [Configuração (API / Variáveis de Ambiente)](#configuração-api--variáveis-de-ambiente)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Arquitetura e Fluxo de Dados](#arquitetura-e-fluxo-de-dados)
- [Testes](#testes)
- [CI / CD](#ci--cd)
- [Melhores Práticas](#melhores-práticas)
- [Como Contribuir](#como-contribuir)
- [Resolução de Problemas](#resolução-de-problemas)
- [Licença e Contato](#licença-e-contato)

---

## Visão Geral
O Projeto Flutter Bolsa tem como objetivo fornecer uma interface móvel responsiva para visualização de cotações em tempo real, gerenciamento de carteira (compra/venda virtual), gráficos simples e feed de notícias financeiras.

## Principais Funcionalidades
- Visualização de cotações em tempo real (ou atualizações periódicas).
- Páginas de detalhe para cada ativo (gráficos, indicadores, notícias).
- Gestão de carteira virtual: adicionar, editar, excluir posições.
- Notificações e alertas (limiares de preço).
- Favoritos e busca por símbolo/nome.
- Modo claro/escuro e suporte a diferentes tamanhos de tela.

## Screenshots
Insira aqui imagens do app (coloque os arquivos no repositório ou no wiki e aponte as URLs):
- Tela inicial / Lista de ativos
- Detalhe do ativo com gráfico
- Carteira / Posições
- Configurações

Exemplo:

![Lista de ativos](assets/docs/screenshots/lista_ativos.png)

## Requisitos
- Flutter SDK >= 3.x
- Dart >= 2.17
- Android SDK / Xcode para builds nativos
- Conexão com API de mercado (ou modo mock para desenvolvimento)

## Instalação e Execução Rápida
1. Clone:
```bash
git clone https://github.com/ramonlopes/Projeto-Flutter-Bolsa.git
cd Projeto-Flutter-Bolsa
```
2. Dependências:
```bash
flutter pub get
```
3. Rode:
```bash
flutter run
```

## Configuração (API / Variáveis de Ambiente)
Use `.env` com flutter_dotenv ou outra estratégia. Exemplo:
```env
API_BASE_URL=https://api.exemplo.com
API_KEY=your_api_key_here
ENABLE_MOCK=false
```

## Estrutura do Projeto
Sugestão:
```
lib/
├─ main.dart
├─ src/
│  ├─ app.dart
│  ├─ modules/
│  │  ├─ home/
│  │  ├─ asset_detail/
│  │  ├─ portfolio/
│  │  └─ settings/
│  ├─ core/
│  │  ├─ models/
│  │  ├─ services/
│  │  ├─ repositories/
│  │  └─ utils/
│  └─ shared/
│     ├─ widgets/
│     └─ themes/
assets/
test/
```

## Arquitetura e Fluxo de Dados
Recomenda-se camadas Presentation / Domain / Data e um gerenciador de estado consistente (Provider / Riverpod / Bloc).

## Testes
- Unitários: `test/unit`
- Widget tests: `test/widget`
```bash
flutter test
```

## CI / CD
Sugestão de job GitHub Actions com flutter analyze, flutter test e build.

## Como Contribuir
Resuma o processo e link para `CONTRIBUTING.md`.

## Resolução de Problemas
- Erro "Missing SDK": ver PATH do Flutter.
- Dependência quebrada: `flutter pub cache repair`.

## Licença e Contato
Escolha uma licença (ex: MIT). Contato: @ramonlopes (GitHub).