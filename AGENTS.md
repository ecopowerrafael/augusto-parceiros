# Doc Motor — instruções para futuras sessões

Antes de implementar qualquer funcionalidade, leia `docs/STATUS-DO-PROJETO.md`, `docs/ARQUITETURA.md`, `docs/REGRAS-DE-NEGOCIO.md`, `docs/DECISOES-TECNICAS.md` e o `README.md`. O `AGENTS.md` fornecido na missão original define os princípios obrigatórios de engenharia e segurança; ele deve ser preservado como referência de trabalho.

## Regras locais

- Trabalhe por fases; a Fase 3.1 foi implementada na branch de desenvolvimento, mas permanece em duas etapas operacionais: primeiro importar e verificar o SQL manual; só depois publicar código dependente na `main`/Hostinger. Não iniciar a Fase 4 sem nova autorização explícita.
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
- Para a Fase 3, executar `database/updates/002_services_pricing_rules_precheck.sql`, depois `database/updates/002_services_pricing_rules.sql` e por fim `database/updates/002_services_pricing_rules_verify.sql`. O proprietário deve confirmar a importação antes de publicar endpoints/telas dependentes.

## Comandos

```bash
npm install
npm run dev
npm run lint
npm run typecheck
npm run test
npm run build
```
