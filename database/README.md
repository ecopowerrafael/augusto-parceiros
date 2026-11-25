# Instalação manual do banco Doc Motor

Esta pasta prepara a instalação da Fase 2 pelo phpMyAdmin. A comunicação com o MySQL da Hostinger já foi comprovada pelos logs do backend usando `127.0.0.1`; o banco estava inicialmente vazio. Os arquivos não executam operações remotas automaticamente.

## Ordem exata

1. No phpMyAdmin, selecione o banco correto, atualmente `u891593158_doc`.
2. Abra a aba **Importar** e importe `database/install.sql`.
3. Execute `database/verify.sql` e confirme as tabelas, a migration `001_initial.sql` e zero órfãos.
4. Gere localmente o hash bcrypt da senha administrativa.
5. Crie uma cópia temporária de `database/create-admin.sql`, substitua somente os placeholders de nome, e-mail e hash, e execute essa cópia no phpMyAdmin.
6. Execute novamente a parte de administradores de `database/verify.sql` e confirme exatamente um administrador.
7. Remova a cópia preenchida do computador quando concluir. Ela não deve ser commitada nem enviada ao GitHub.

Não execute `scripts/migrate.mjs` nem `scripts/provision-admin.mjs` para este procedimento manual. Eles permanecem disponíveis para ambientes que tenham terminal e não devem ser combinados com o SQL manual sem conferir `schema_migrations`.

## Gerar o SQL administrativo temporário

No diretório do projeto, execute localmente o script abaixo. Ele solicita a senha com `Read-Host -AsSecureString`, usa `bcryptjs` com custo `12`, preenche uma cópia de `create-admin.sql` e grava o arquivo fora do repositório em `%TEMP%`:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\generate-admin-sql.ps1
```

O comando imprime o caminho exato do SQL temporário gerado. Importe esse arquivo no phpMyAdmin e remova-o após o uso. Não use hashes de exemplo ou senhas padrão.

## Falhas parciais

O arquivo usa `CREATE TABLE IF NOT EXISTS` e não contém `DROP TABLE`/`DROP DATABASE`. A tabela `schema_migrations` só recebe `001_initial.sql` quando as oito tabelas da Fase 2 estão presentes. Se a importação interromper, não marque a instalação como concluída: execute `verify.sql`, corrija o erro no phpMyAdmin e importe `install.sql` novamente. Antes de repetir, confirme se o erro não deixou uma tabela com estrutura incompleta.

O MySQL pode confirmar DDL individualmente; por isso, a ausência do registro em `schema_migrations` é o sinal de que a instalação não deve ser considerada completa. Não crie manualmente esse registro sem validar todas as tabelas.

## Atualizações futuras

Cada atualização deve ser um novo arquivo SQL versionado, por exemplo `002_nome.sql`, acompanhado de instruções de pré-verificação, execução e verificação. O SQL de instalação manual correspondente deve registrar o nome da migration somente depois da estrutura daquela versão existir. Nunca reutilize ou edite uma migration já aplicada para alterar produção.

## Fase 3 — serviços, preços e regras

Para um banco que já recebeu a Fase 2, selecione o banco correto no phpMyAdmin e execute exatamente nesta ordem:

1. `updates/002_services_pricing_rules_precheck.sql` — somente leitura; confirma o banco e se a migration não foi registrada.
2. `updates/002_services_pricing_rules.sql` — cria onze tabelas, seeds de UFs/categorias/serviços e oito regras preliminares `DRAFT`; não cria preços reais.
3. `updates/002_services_pricing_rules_verify.sql` — somente leitura; confirma tabelas, migration, serviços, regras e contagens.

Para um banco novo, `database/install.sql` já contém a Fase 2 e a Fase 3 completas. Não execute o instalador completo sobre um banco existente sem análise.

Se o phpMyAdmin interromper a importação, não registre a migration manualmente e não prossiga para o painel. Salve a mensagem do erro, execute novamente o precheck e compare as onze tabelas esperadas. Como os comandos usam `CREATE TABLE IF NOT EXISTS` e seeds idempotentes, a retomada deve ser feita somente após identificar a causa. Não há `DROP TABLE` ou `DROP DATABASE` nesses arquivos.

Após a confirmação da importação, a implementação dos endpoints e telas administrativas será feita em etapa separada e publicada na `main` somente depois dos testes locais.
