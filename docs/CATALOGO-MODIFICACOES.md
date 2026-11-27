# Catálogo de modificações veiculares

O catálogo central é persistido em `vehicle_modifications` e suas tabelas de categorias, UFs, documentos e mensagens. Ele é reutilizável por serviços futuros e não representa aprovação legal automática.

Cada item possui código estável, status, ordem, cobrança vinculada, aplicabilidade, requisitos de autorização/CSV/ECV, indicação de análise manual, descrição complementar, fonte oficial e estado jurídico. Quando a fonte ou a condição não estiver confirmada, o item permanece `A_CONFIRMAR` e deve ser encaminhado para análise manual.

O cadastro de motor não pertence a este catálogo e não pode ser selecionado como modificação adicional. Suspensão e rodas/pneus possuem cobranças próprias; modificações adicionais usam cobrança por item válido.

As exigências documentais aceitam `REQUIRED`, `DISPENSED`, `CONDITIONAL` e `A_CONFIRMAR`. A configuração administrativa deve preservar versões históricas dos serviços.
