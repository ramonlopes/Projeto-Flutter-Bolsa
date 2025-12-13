# CONTRIBUTING.md

Obrigado por querer contribuir com o Projeto Flutter Bolsa! Este documento descreve o fluxo de contribuição, padrões de código, como abrir issues e pull requests, e outras diretrizes úteis.

## Antes de começar
- Leia o README e o wiki do projeto.
- Verifique as issues abertas para evitar trabalho duplicado.

## Como contribuir
1. Fork o repositório e clone o seu fork:
```bash
git clone https://github.com/<seu-usuario>/Projeto-Flutter-Bolsa.git
cd Projeto-Flutter-Bolsa
```
2. Crie uma branch com prefixo apropriado:
```bash
git checkout -b feature/minha-nova-feature
# ou
git checkout -b fix/corrige-bug
```
3. Faça mudanças pequenas e atômicas. Cada PR deve ter escopo claro.
4. Rode linters e testes antes de submeter o PR:
```bash
flutter pub get
flutter analyze
flutter test
```
5. Commit e push:
```bash
git add .
git commit -m "[feature] descrição curta do que foi feito"
git push origin feature/minha-nova-feature
```
6. Abra um Pull Request do seu fork para o repositório original.

## Formato de commits
- Use mensagens descritivas e no tempo presente, ex: `feat: adiciona busca por símbolo`
- Prefixos recomendados: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`

## Revisão de PR
- Todo PR deve ter:
  - Descrição do que foi feito
  - Como testar (passos)
  - Screenshots quando aplicável
  - Checklist de testes
- Responda comentários do revisor e atualize o PR conforme solicitado.

## Issues
- Ao abrir uma issue, forneça:
  - Um título claro
  - Passos para reproduzir (se for bug)
  - Logs ou mensagens de erro
  - Versão do Flutter/Dart e plataforma (Android/iOS)

## Estilo de código
- Siga as recomendações do Dart/Flutter (use `dart format` e `flutter analyze`).
- Nomeie classes, métodos e variáveis de forma clara e consistente.

## Testes
- Adicione testes unitários para lógica importante.
- Inclua testes de widget para componentes principais quando possível.

## Licença
Ao contribuir, você concorda que suas contribuições serão licenciadas sob a licença do projeto.