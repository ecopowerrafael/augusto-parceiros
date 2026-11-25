# Regras de viabilidade — Fase 3

## Estado atual

O SQL cria `technical_rules` e `technical_rule_services` para armazenar regras versionadas, por serviço, categoria de veículo e UF. As oito regras preliminares são inseridas como `DRAFT` e não podem alimentar cálculo automático.

Os resultados armazenados (`VIABLE`, `OUT_OF_CRITERIA`, `VIABLE_WITH_REQUIREMENTS` e `MANUAL_REVIEW`) são classificações operacionais internas. Nunca devem ser apresentados como garantia de aprovação pelo Detran.

## Conteúdo das regras

Condições e limites ficam em JSON para permitir evolução sem alterar o schema a cada novo parâmetro técnico. A aplicação deverá validar o formato com Zod no backend, versionar alterações e manter referência, data da última verificação e notas internas.

## Segurança operacional

- Somente administradores autorizados poderão criar, editar, ativar ou arquivar regras.
- Regras `DRAFT` não entram em consultas de viabilidade.
- Uma alteração deve gerar auditoria e preservar a versão anterior.
- Dados ausentes, inválidos ou categorias sem regra devem resultar em análise manual, nunca em inferência.
- A integração Simples API e o motor automático não fazem parte desta etapa.
