# Doc Motor — instruções para futuras sessões

Antes de implementar qualquer funcionalidade, leia `docs/STATUS-DO-PROJETO.md`, `docs/ARQUITETURA.md`, `docs/REGRAS-DE-NEGOCIO.md`, `docs/DECISOES-TECNICAS.md` e o `README.md`. O `AGENTS.md` fornecido na missão original define os princípios obrigatórios de engenharia e segurança; ele deve ser preservado como referência de trabalho.

## Regras locais

- Trabalhe por fases; as migrations 001, 002 e 003 da Fase 3 foram confirmadas no banco remoto. A Fase 3.1 está implementada e a Fase 3.2 está em homologação autenticada. Não iniciar a Fase 4 sem nova autorização explícita.
- O backend é a autoridade para autenticação, autorização, tenant, limites e regras de negócio.
- Não versionar `.env`, credenciais, tokens ou documentos pessoais.
- Ao mudar schema, atualizar `docs/BANCO-DE-DADOS.md` e planejar migration/rollback.
- Ao mudar autenticação ou autorização, atualizar `docs/AUTENTICACAO-E-PERMISSOES.md` e revisar a matriz de acesso.
- Ao concluir uma missão, atualize `CHANGELOG.md` e `docs/STATUS-DO-PROJETO.md`.
- Execute `npm run lint`, `npm run typecheck`, `npm run build` e os testes relevantes antes de entregar.
- Não afirmar que algo foi testado sem executar a verificação.
- O ambiente de homologação oficial é a Hostinger; depois de publicar na `main`, registrar se o teste online foi realmente executado.
- Fluxo permanente: implementar localmente → lint/typecheck/test/build → commit → publicar na `main` → validar na Hostinger por HTTP → corrigir e registrar evidências.
- A conferência visual fica sob responsabilidade humana quando o controle automatizado do navegador não estiver disponível; registrar como pendente, sem inventar resultado.
- Nunca adicionar senha de banco, chave de API ou dado de cliente ao código, logs, documentação ou commits.
- Para autenticação, use sessões opacas persistidas no MySQL, cookies HttpOnly/Secure/SameSite, CSRF e rate limit persistido; não use tokens de autenticação em localStorage.
- A recuperação de senha depende de SMTP configurado no ambiente; nunca retornar o token de recuperação na API.
- A instalação inicial do MySQL desta fase é manual pelo phpMyAdmin usando `database/install.sql`; não executar migrations, provisionamento ou operações remotas sem autorização explícita da missão.
- A Migration 002 já está instalada no banco remoto e não deve ser reimportada; a Migration 003 também foi confirmada. Não executar novamente esses SQLs. Qualquer alteração estrutural futura exige nova migration e confirmação explícita antes da publicação.
- A Hostinger usa importação manual pelo phpMyAdmin; não depender de SSH, CLI MySQL ou execução de migrations no terminal remoto. Migrations canônicas permanecem portáveis e nunca recebem o nome do banco.
- Toda alteração de banco deve entregar três SQLs manuais: pré-verificação somente leitura, atualização incremental e verificação posterior, além de manter `database/install.sql` atualizado.
- SQLs manuais da Hostinger devem iniciar com `USE \`u891593158_doc\`;` e `SELECT DATABASE() AS selected_database;`, qualificar tabelas da aplicação com `\`u891593158_doc\`.`, filtrar `information_schema` por `table_schema = 'u891593158_doc'` e ser gerados por `scripts/generate-hostinger-sql.mjs`. O gerador valida o identificador, não inclui credenciais e não executa SQL remoto.
- Não alterar migrations já aplicadas. Como 001 e 002 estão instaladas, alterações estruturais futuras começam na migration 003; não repetir seeds antigos, não usar DROP/TRUNCATE, não desabilitar foreign keys e não prometer rollback transacional completo para DDL.

## Comandos

```bash
npm install
npm run dev
npm run lint
npm run typecheck
npm run test
npm run build
```
