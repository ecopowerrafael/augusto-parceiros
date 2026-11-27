# Catálogo e formulários declarativos

O catálogo de modificações é persistido em `vehicle_modifications` e seus vínculos de categoria/UF. Os simuladores não mantêm listas comerciais fixas: carregam o catálogo autorizado pelo backend e filtram itens ativos, compatíveis e ainda não selecionados. O backend permanece como autoridade para status, duplicidade, categoria, UF, descrição e cobrança.

Os simuladores integrado ao construtor e declarativo utilizam `src/simulator/ServiceFieldRenderer.tsx`. O componente concentra campos, condições de visibilidade, opções de UF, checklists semânticos e grupos repetíveis de modificações adicionais. Valores internos como `YES`, `NO`, `UNKNOWN`, `SP` e `OTHER_STATE` não dependem dos textos exibidos.

O PBT só é renderizado quando uma regra técnica aplicável à categoria referencia esse campo. A ausência de vínculo de UF no catálogo não representa aprovação legal. A Migration 010 já aplicada contém o tipo `REPEATABLE_MODIFICATIONS`; a Migration 011 é necessária apenas para atualizar rótulos persistidos dos checklists e registrar a regra declarativa de `OTHER_STATE` para suspensão. Ela não altera o catálogo nem os valores comerciais.
Na Fase 3.16, foi preparada historicamente uma seção declarativa de documentação da suspensão, mas a Migration 013 está suspensa e fora do fluxo ativo. Esses campos serão implementados no componente React próprio da suspensão em fase futura.
# Transição híbrida — Fase 3.18

O cadastro de motor utiliza o contrato operacional `MOTOR_V1`, definido em código no frontend e backend. A renderização do fluxo de motor não depende das tabelas de seções, campos ou opções declarativas. Essas tabelas permanecem preservadas para compatibilidade, rollback e serviços ainda não migrados.

O catálogo persistido continua sendo a fonte de dados para modificações adicionais de outros serviços. Preços, comissões, permissões e disponibilidade nunca são aceitos do frontend como autoridade.
