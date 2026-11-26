# Homologação — Fase 3.7

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

## Verificações executadas

- `npm test -- --run --pool=threads --minWorkers=1 --maxWorkers=1`: 87 testes aprovados.
- `npm run lint`: aprovado.
- `npm run typecheck`: aprovado.
- `npm run build`: aprovado.
- `node --check` nos módulos Node alterados: aprovado.
- `git diff --check`: aprovado.

## Migration 006

Ainda pendente de importação manual pelo proprietário. Executar no phpMyAdmin, nesta ordem:

1. `database/updates/006_simulator_input_normalization_precheck.sql`
2. `database/updates/006_simulator_input_normalization.sql`
3. `database/updates/006_simulator_input_normalization_verify.sql`

Nenhum SQL remoto foi executado por esta missão. Após a confirmação do verify, publicar a branch na `main` e repetir a validação online com dados fictícios.
