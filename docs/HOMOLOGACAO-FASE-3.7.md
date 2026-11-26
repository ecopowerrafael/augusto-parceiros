# Homologação — Fase 3.7

## Fase 3.7.1 — correção da configuração real

O HTTP 422 confirmado na Hostinger foi reproduzido pela validação de `vehicle_target.plate_pattern`: a cobrança persistida referenciava um campo derivado calculado no backend, mas o validador só conhecia `service_form_fields`. A correção reconhece explicitamente os dois padrões derivados, exige seus campos de placa de origem e mantém a validação de referências ativa. Não foi criada Migration 007 porque não há coluna ou registro faltante no banco.

O teste de integração `server/service-simulation.integration.test.js` usa os 13 campos, opções, cobrança, regra e cálculo equivalentes ao seed das migrations 002/003 e chama o mesmo contrato de simulação usado pela rota. O cenário `AAA2222`/`BBB4444`, 66 CV e `2.2`, retorna 2200 cm³, variação 0%, `externalCalls=0` e total de R$ 975,80.

## Escopo

Correção do simulador NO-CODE sem integração real com a Simples API, sem consumo de créditos e sem operações no banco remoto.

## Contratos corrigidos

- Combustíveis usam `ALCOHOL`, `GASOLINE`, `DIESEL` e `FLEX`; `Álcool` e `Etanol` são equivalentes.
- Placas aceitam entrada minúscula, espaços, hífens e colagem; o backend normaliza para o padrão antigo ou Mercosul.
- Cilindradas aceitam vírgula/ponto, litros ou cm³ e são comparadas internamente em cm³.
- Placa antiga somente no veículo de destino aplica `OLD_PLATE_AUTHORIZATION`; a placa doadora não dispara essa cobrança.
- A avaliação continua declarativa e sem chamadas externas.

## Cenário do proprietário

Dados fictícios: Automóvel, SP, destino `abc1234`, 75 CV, 2000 cm³, gasolina, nota fiscal; origem por placa `abc2345`, 75 CV, 2000 cm³, gasolina.

O fixture automatizado também cobre a equivalência Álcool/Etanol e litros/cm³. Com os valores comerciais persistidos, o total conhecido é:

`R$ 295,80 + R$ 160,00 + R$ 300,00 + R$ 220,00 = R$ 975,80`.

O resultado é uma simulação operacional, não garantia de aprovação pelo Detran.

## Causa raiz do erro anterior

O endpoint estava recebendo respostas sem uma etapa central de normalização: combustível persistido como texto não tinha opções padronizadas, cilindradas digitadas com vírgula/litros podiam chegar em formatos diferentes e a interface renderizava campos genéricos sem máscara/seletor semântico. Além disso, o `catch` da rota convertia qualquer falha de avaliação em uma mensagem genérica, ocultando o código de entrada inválida. A correção passou a normalizar as respostas no backend antes de `calculateFields`/regras, enviar as opções persistidas ao avaliador, renderizar os controles de entrada apropriados e retornar erros específicos; a Simples API continua fora do fluxo e `externalCalls` permanece zero.

## Verificações executadas

- `npm test -- --run --pool=threads --minWorkers=1 --maxWorkers=1`: 87 testes aprovados.
- `npm run lint`: aprovado.
- `npm run typecheck`: aprovado.
- `npm run build`: aprovado.
- `node --check` nos módulos Node alterados: aprovado.
- `git diff --check`: aprovado.

Os testes cobrem explicitamente `2.5 → 2500`, `2,5 → 2500`, `125 → 125` e `2500 → 2500`, além da simulação manual, simulação por placa fictícia, quatro combustíveis e cobrança baseada somente na placa de destino.

## Homologação online

O proprietário deve executar a conferência autenticada no ambiente Hostinger. A tentativa HTTP desta sessão não foi conclusiva porque o ambiente local não resolveu `docmotor.online`; não há evidência automatizada de propagação online nesta sessão.

## Migration 006

Importada e validada manualmente pelo proprietário no banco `u891593158_doc`, MariaDB `11.8.9-MariaDB-log`. O verify confirmou registro da migration, os dois campos de combustível como `SINGLE_SELECT`, os dois campos de cilindrada com unidade `cm³`, oito opções de combustível e placas preservadas como `VEHICLE_PLATE`.

Os arquivos foram executados no phpMyAdmin, nesta ordem:

1. `database/updates/006_simulator_input_normalization_precheck.sql`
2. `database/updates/006_simulator_input_normalization.sql`
3. `database/updates/006_simulator_input_normalization_verify.sql`

O projeto não executou SQL remoto. Após o merge, a homologação autenticada online com dados fictícios permanece pendente de validação humana.
