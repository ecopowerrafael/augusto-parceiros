# Comissionamento de parceiros

## Estado

A Fase 3.5 implementa o modelo genérico de comissão, mas o modelo inicial instalado é `NONE`: nenhum valor comercial é calculado ou publicado. A API nunca deve confiar em valores enviados pelo frontend.

## Modelos previstos

`NONE`, `SERVICE_PERCENTAGE`, `HONORARIUM_PERCENTAGE`, `FULL_HONORARIUM` e `FIXED_AMOUNT`. Os valores são calculados em centavos no backend e os itens elegíveis dependem de classificação semântica (`charge_nature = HONORARY` e `is_public_fee`), não do nome do serviço. Sem override individual, aplica-se a configuração global; `NONE` é uma escolha explícita de desativação.

## Banco

O proprietário importou `migrations/004_partner_commissions.sql` manualmente pelo phpMyAdmin no banco `u891593158_doc`. O verify confirmou as duas tabelas, registro da migration, configuração `NONE` e zero overrides inválidos. Não importe novamente.

## Homologação

Use os casos unitários em `server/commissions.test.js`. Antes de ativar qualquer modelo, valide no ambiente real a leitura da configuração, a persistência do override e a auditoria administrativa.
