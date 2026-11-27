# Estrutura operacional

## Objetivo

A Fase 3.15 separa a configuração administrativa da operação dos serviços. O construtor e o simulador declarativo continuam em `Configuração de serviços`; as rotas de serviço possuem títulos próprios e reutilizam o mesmo renderer declarativo, avaliador, resultado e gerador de PDF.

## Navegação

Administradores acessam gestão, serviços, configurações e conta. Parceiros acessam sua visão geral, serviços operacionais liberados e conta. Rotas de serviços ainda não configuradas exibem uma página de desenvolvimento explícita, sem dados fictícios, chamadas externas ou documentos oficiais.

O endereço legado `/admin/simulador-declarativo` permanece compatível e retorna ao contexto de `Configuração de serviços`; ele não é mais exibido como item operacional do menu.

## Fonte de verdade

Serviços, versões, seções, campos, opções, cobranças, documentos, mensagens, regras e catálogo de modificações permanecem no MySQL. O React não contém listas comerciais ou regras legais específicas. O backend continua responsável por autenticação, autorização, isolamento da empresa, validação, avaliação e totais.

## Componentes compartilhados

- `ServiceFieldRenderer`: campos, opções condicionais, PBT, checklists e grupos repetíveis.
- `evaluateDeclarativeCondition`: condições persistidas sem `eval`.
- `ServiceResultView`: situação, cobranças, documentos, mensagens e ações de PDF/compartilhamento.
- `generateSimulationPdf`: gerador único do PDF de simulação.
- `DeclarativeSimulationPage`: carrega o serviço pelo código persistido e não por formulário específico em código.

As páginas operacionais devem parametrizar o código do serviço e continuar usando essas mesmas camadas. Para parceiros, a API aceita apenas versões `PUBLISHED` de serviços ativos e explicitamente disponíveis ao perfil; configurações administrativas e rascunhos não são expostos. Serviços sem configuração publicada permanecem em desenvolvimento até serem configurados e homologados pelo proprietário.

## Estado da Fase 3.15

A versão `0.4.11` cria a navegação operacional e torna a página declarativa parametrizável. Foi integrada na `main` pelo merge `4778456`; não há Migration 013 nesta etapa, pois não foi comprovada necessidade de alterar o schema.
