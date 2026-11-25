# Gestão de serviços — Fase 3

## Escopo e implementação

O catálogo administrativo possui serviços principais e complementares, código estável, slug amigável, descrições, categoria, ordem de exibição, status, disponibilidade para clientes e parceiros e associação opcional a categorias de veículo e UFs. O editor em `src/auth/AuthPages.tsx` usa a mesma experiência genérica para qualquer serviço.

As tabelas são `services`, `vehicle_categories`, `brazilian_states`, `service_vehicle_categories`, `service_ufs` e `service_relations`. A landing page existente continua sendo conteúdo comercial; o catálogo administrativo será sua fonte operacional futura.

## Regras de operação

- `code` e `slug` são únicos e não devem ser reutilizados para outro serviço.
- Desativar é preferível a apagar quando houver histórico ou referência.
- Serviço complementar pode ser relacionado a um serviço principal com condição textual.
- A disponibilidade por UF/categoria é configuração; não representa aprovação do Detran.
- Toda alteração administrativa deverá registrar usuário responsável e auditoria quando o CRUD for implementado.

## Dependência de implantação

O backend implementa criação, edição, duplicação, versões, seções, campos, opções, cobranças, regras, ações, documentos e simulador. Todas as configurações novas iniciam como rascunho e são protegidas por perfil administrativo, CSRF e auditoria. A funcionalidade depende da importação manual pelo phpMyAdmin para execução online.
