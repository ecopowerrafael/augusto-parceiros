# Catálogo e formulários declarativos

O catálogo de modificações é persistido em `vehicle_modifications` e seus vínculos de categoria/UF. Os simuladores não mantêm listas comerciais fixas: carregam o catálogo autorizado pelo backend e filtram itens ativos, compatíveis e ainda não selecionados. O backend permanece como autoridade para status, duplicidade, categoria, UF, descrição e cobrança.

Os simuladores integrado ao construtor e declarativo utilizam `src/simulator/ServiceFieldRenderer.tsx`. O componente concentra campos, condições de visibilidade, opções de UF, checklists semânticos e grupos repetíveis de modificações adicionais. Valores internos como `YES`, `NO`, `UNKNOWN`, `SP` e `OTHER_STATE` não dependem dos textos exibidos.

O PBT só é renderizado quando uma regra técnica aplicável à categoria referencia esse campo. A ausência de vínculo de UF no catálogo não representa aprovação legal. A Migration 010 já aplicada contém o tipo `REPEATABLE_MODIFICATIONS`; a Migration 011 é necessária apenas para atualizar rótulos persistidos dos checklists e registrar a regra declarativa de `OTHER_STATE` para suspensão. Ela não altera o catálogo nem os valores comerciais.
Na Fase 3.16, o serviço `LOWERED_SUSPENSION` recebe a seção declarativa “Documentação da modificação”, com `suspension.parts_invoice` e `suspension.installation_invoice`. Ambos são `SINGLE_SELECT`, obrigatórios e sem valor padrão; suas opções persistidas exibem rótulos completos em português. Os dados são informativos e não alteram cobranças ou prometem aprovação.
