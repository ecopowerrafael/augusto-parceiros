# Política de preços — Fase 3

## Modelo preparado

`price_tables` representa uma versão comercial identificável, com status e validade. `service_prices` permite preço por serviço, perfil comercial, parceiro, categoria de veículo e UF. `service_price_components` permite separar honorários, taxas, inspeção e outros componentes sem misturar valores.

Nenhum preço real é inserido pelo SQL da Fase 3. Os registros usam `amount_cents` para evitar problemas de arredondamento e permanecem vazios até definição administrativa.

## Princípios

- Uma tabela de preços deve ser identificável e possuir período de validade quando publicada.
- Valores e componentes usados em futuros orçamentos deverão ser preservados como snapshot no orçamento; não será permitido recalcular histórico com a tabela atual.
- O backend deverá validar o escopo do parceiro e não aceitar `partner_company_id` arbitrário enviado pelo frontend.
- Preço não é garantia de viabilidade técnica ou aprovação por órgão público.
- A publicação de uma tabela e seus preços deverá ser auditável.

## Estados previstos

`DRAFT` é o estado inicial. Estados de publicação e arquivamento serão definidos na implementação do painel, com validação de datas, duplicidade e permissões.
