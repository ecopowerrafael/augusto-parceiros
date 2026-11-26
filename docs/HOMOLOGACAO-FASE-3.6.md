# Homologação da Fase 3.6 — simulador NO-CODE

## Escopo

Os cenários abaixo executam diretamente o mesmo `evaluateService` utilizado pela rota administrativa `POST /api/admin/service-versions/:versionId/simulate`. A fixture usa campos manuais, campos calculados, cobranças, regras, documentos e placas fictícias. Nenhuma chamada à Simples API é feita e nenhum crédito externo é consumido.

## Resultado dos cenários locais

| Cenário | Resultado esperado | Bloqueio automático | Evidência adicional |
|---|---|---:|---|
| Motor equivalente com nota fiscal | Não classificado automaticamente | Não | Cadastro base e documento condicional avaliados |
| Motor equivalente sem nota fiscal | Não classificado automaticamente | Não | Cobrança condicional de análise sem nota |
| Destino com placa antiga | Não classificado automaticamente | Não | Padrão OLD derivado da placa e cobrança de placa |
| Origem antiga e destino Mercosul | Não classificado automaticamente | Não | Padrão da origem não altera a regra do destino |
| Aumento de potência de 5% | Análise manual | Não | Solicitação de modificação + ITL/CSV sem valor definido |
| Aumento de exatamente 10% | Análise manual | Não | Limite inclusivo confirmado |
| Aumento superior a 10% | Fora dos critérios | Sim | Ação de bloqueio automático |
| Redução de potência | Análise manual | Não | ITL/CSV exigido; valor desconhecido permanece pendente |
| Alteração de combustível | Análise manual | Não | Regra de combustível divergente acionada |
| Mesma potência com cilindrada diferente | Análise manual | Não | Regra genérica de cilindrada divergente |
| Dados técnicos incompletos | Análise manual | Não | Ausência não é convertida em zero |
| Motocicleta com cilindrada diferente | Fora dos critérios | Sim | Regra específica de motocicleta |
| Alternância placa/manual | Executado | Não | Consulta por placa é substituível por preenchimento manual |

### Comando executado

```bash
npm test -- --run server/service-simulator.test.js --pool=threads --minWorkers=1 --maxWorkers=1
```

Resultado: **13 testes aprovados**.

## Observação sobre valores

`ITL_CSV_INSPECTION` possui `default_amount_cents = null`. O resultado o mantém em `missing_amount_items`; isso significa valor pendente de configuração, nunca gratuidade.

## Homologação administrativa pendente

A criação visual de um segundo serviço demonstrativo (“Regularização de suspensão rebaixada”) ainda depende de execução autenticada pelo proprietário na interface da Hostinger. O código não cria esse serviço automaticamente, não publica preços e não substitui o construtor por regras específicas em JavaScript.

## Limitações

O navegador automatizado não foi utilizado. A apresentação visual do resultado e a criação do segundo serviço devem ser conferidas manualmente no ambiente online.
