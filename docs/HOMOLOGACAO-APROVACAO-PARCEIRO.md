# Homologação da aprovação de parceiro

## Diagnóstico inicial

Execute `database/verify-admin-approval.sql` no phpMyAdmin. Ele é somente leitura e confirma as colunas, FKs, administrador ativo e integridade dos vínculos sem exibir credenciais, hashes ou tokens.

## Teste funcional

Use somente um cadastro fictício criado para homologação. No painel administrativo, execute os estados nesta ordem, registrando o resultado HTTP e o `X-Request-ID`:

1. `PENDING → ACTIVE`: confirme que a empresa e o usuário proprietário ficam `ACTIVE`, que `approved_at`/`approved_by` são preenchidos e que existe auditoria `PARTNER_ACTIVE`.
2. `ACTIVE → SUSPENDED`: confirme que a empresa e todos os usuários vinculados ficam `SUSPENDED`, com auditoria `PARTNER_SUSPENDED`.
3. `SUSPENDED → ACTIVE`: confirme a reativação do acesso e nova auditoria `PARTNER_ACTIVE`.
4. `PENDING → REJECTED`: confirme `REJECTED`, motivo persistido, usuário vinculado recusado e auditoria `PARTNER_REJECTED`.

Após suspensão, uma chamada autenticada aos painéis operacionais deve ser recusada por `ACCOUNT_NOT_ACTIVE`. Após aprovação, o acesso deve funcionar.

## Falha

Se a interface mostrar `PARTNER_STATUS_UPDATE_FAILED`, copie apenas o request ID. Nos logs privados da Hostinger procure `admin_partner_status_failed`; o registro contém `code`, `errno` e `sqlState`, mas não contém senha, token, documento ou payload completo. Não repetir a operação indefinidamente antes de identificar o código SQL.
