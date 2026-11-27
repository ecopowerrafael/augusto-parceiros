# Homologação — Fase 3.15

Branch: `feature/fase-3-15-estrutura-operacional`  
Versão: `0.4.11`  
Ambiente: Hostinger staging, com indexação desabilitada.

## Roteiro

1. Entrar como administrador e conferir os grupos Gestão, Serviços, Configurações e Conta.
2. Confirmar que o item genérico “Simulador declarativo” não aparece no menu.
3. Abrir a rota legada `/admin/simulador-declarativo` e confirmar o retorno ao contexto de configuração.
4. Abrir Regularização de motor e Regularizar suspensão; confirmar que cada página usa o serviço persistido pelo código, sem lista fixa no frontend.
5. Conferir Outras modificações, Emissor de CRLV e Consultas: devem informar desenvolvimento, sem resultados fictícios ou chamadas externas.
6. Entrar como parceiro aprovado e verificar que não aparecem configurações administrativas, catálogo interno, chaves de API ou dados de outras empresas.
7. Conferir as rotas de serviços do parceiro e os avisos de funcionalidades ainda não liberadas.
8. No simulador de suspensão, testar zero, uma e várias modificações adicionais, remoção intermediária, alternância Sim/Não e campos ocultos.
9. Testar os checklists, análise manual para outros estados, totais, PDF e WhatsApp com dados fictícios.
10. Repetir a conferência em aproximadamente 1920, 1366, 768 e 390 pixels.

## Limitações conhecidas

- A verificação visual real depende do acesso do proprietário à Hostinger; não deve ser inferida pelos testes automatizados.
- Emissor de CRLV e Consultas não executam operações externas nesta fase.
- O fluxo comercial de orçamento persistido e solicitações de serviço ainda não está implementado.
- Não consumir a Simples API e não usar dados reais de clientes.
