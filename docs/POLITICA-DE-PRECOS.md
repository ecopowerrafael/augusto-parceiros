# Política de preços — Fase 3

## Modelo preparado

`price_tables` permanece disponível para políticas por vigência. O catálogo reutilizável está em `billing_items`, e a composição de cada versão em `service_billing_items`. Assim, um serviço soma vários itens aplicáveis; não existe um único `service.price` como fonte definitiva.

Os itens comerciais autorizados pelo proprietário são semeados como `DRAFT`, em centavos, com natureza e status de valor explícitos. Itens como CSV sem valor continuam ausentes/sob consulta. Eles não são apresentados como taxas públicas oficiais.

## Princípios

- Uma tabela de preços deve ser identificável e possuir período de validade quando publicada.
- Valores e componentes usados em futuros orçamentos deverão ser preservados como snapshot no orçamento; não será permitido recalcular histórico com a tabela atual.
- O backend deverá validar o escopo do parceiro e não aceitar `partner_company_id` arbitrário enviado pelo frontend.
- Preço não é garantia de viabilidade técnica ou aprovação por órgão público.
- A publicação de uma tabela e seus preços deverá ser auditável.

## Estados previstos

`DRAFT` é o estado inicial. Estados de publicação e arquivamento serão definidos na implementação do painel, com validação de datas, duplicidade e permissões.
