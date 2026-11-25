# Regras de viabilidade — Fase 3

## Estado atual

O SQL cria `technical_rules`, `technical_rule_actions` e `technical_rule_services` para armazenar regras versionadas, por serviço, categoria de veículo e UF. As oito regras preliminares são inseridas como `DRAFT`. O avaliador declarativo do backend pode ser usado pelo simulador, mas regras não publicadas não entram em fluxos comerciais.

Os resultados armazenados (`VIABLE`, `OUT_OF_CRITERIA`, `VIABLE_WITH_REQUIREMENTS` e `MANUAL_REVIEW`) são classificações operacionais internas. Nunca devem ser apresentados como garantia de aprovação pelo Detran.

## Conteúdo das regras

Condições, limites e ações ficam em JSON estruturado, validado por Zod e construído pela interface. O backend rejeita campos inexistentes, profundidade excessiva, operadores não suportados e dependências circulares de campos calculados. Não há `eval`, JavaScript, SQL ou URL arbitrário configurável.

## Segurança operacional

- Somente administradores autorizados poderão criar, editar, ativar ou arquivar regras.
- Regras `DRAFT` não entram em consultas de viabilidade.
- Uma alteração deve gerar auditoria e preservar a versão anterior.
- Dados ausentes, inválidos ou categorias sem regra devem resultar em análise manual, nunca em inferência.
- A integração Simples API e o motor automático não fazem parte desta etapa.
