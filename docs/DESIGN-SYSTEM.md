# Design System dos painéis — Fase 3.6

## Objetivo

As áreas autenticadas usam um shell SaaS consistente, separado visualmente do site comercial. O backend continua sendo a autoridade para permissões, dados, cálculos e estados.

## Estrutura

- `app-shell`: ocupa a viewport inteira e evita o layout centralizado da área pública.
- `dashboard-sidebar`: navegação por perfil, grupos de operação/configuração/conta e itens futuros marcados como “Em breve”.
- `dashboard-topbar`: identidade do usuário e perfil atual.
- `dashboard-content`/`page-heading`: título objetivo da tela, sem saudação repetida.
- Cards e tabelas: fundo branco, bordas sutis, raio pequeno e espaçamento consistente.

## Tokens visuais

- Primário de interação: azul `#2563eb`.
- Sidebar: azul-marinho `#111827`.
- Fundo: `#f4f6f8`.
- Texto: `#172033`; texto auxiliar: `#64748b`.
- Erro/destrutivo: vermelho; sucesso: verde; pendência: amarelo.

## Regras de interface

- Layout responsivo sem overflow horizontal; em telas menores a navegação passa para bloco recolhível visualmente compacto.
- Valores monetários aparecem em reais na interface e permanecem em centavos no backend.
- Códigos técnicos e status são traduzidos antes da exibição.
- Itens não implementados não simulam operação: usam o rótulo “Em breve” e não são links acionáveis.
- Alteração de senha fica em “Minha conta”, não repetida em todas as telas.

## Limites da fase

O construtor no-code continua usando o avaliador declarativo existente. A Fase 3.6 não integra a Simples API real, não cria orçamento definitivo e não persiste resultados de simuladores como registros financeiros.
