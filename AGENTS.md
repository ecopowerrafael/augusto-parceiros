# Doc Motor — instruções para futuras sessões

Antes de implementar qualquer funcionalidade, leia `docs/STATUS-DO-PROJETO.md`, `docs/ARQUITETURA.md`, `docs/REGRAS-DE-NEGOCIO.md`, `docs/DECISOES-TECNICAS.md` e o `README.md`. O `AGENTS.md` fornecido na missão original define os princípios obrigatórios de engenharia e segurança; ele deve ser preservado como referência de trabalho.

## Regras locais

- Trabalhe por fases; não inicie a Fase 2 sem autorização explícita.
- O backend é a autoridade para autenticação, autorização, tenant, limites e regras de negócio.
- Não versionar `.env`, credenciais, tokens ou documentos pessoais.
- Ao mudar schema, atualizar `docs/BANCO-DE-DADOS.md` e planejar migration/rollback.
- Ao concluir uma missão, atualize `CHANGELOG.md` e `docs/STATUS-DO-PROJETO.md`.
- Execute `npm run lint`, `npm run typecheck`, `npm run build` e os testes relevantes antes de entregar.
- Não afirmar que algo foi testado sem executar a verificação.

## Comandos

```bash
npm install
npm run dev
npm run lint
npm run typecheck
npm run test
npm run build
```
