# Homologação da Fase 3.14

## Situação

- Versão: `0.4.10`.
- Migration 011: aplicada e verificada pelo proprietário no banco `u891593158_doc`.
- Migration 012: necessária para corrigir a semântica persistida dos checklists; ainda não aplicada.
- Publicação na `main`: bloqueada até a aplicação e verificação da Migration 012.
- Homologação visual/funcional: pendente.

## Correção pendente de banco

Executar somente após autorização, nesta ordem:

1. `database/updates/012_suspension_checklist_semantics_precheck.sql`
2. `database/updates/012_suspension_checklist_semantics.sql`
3. `database/updates/012_suspension_checklist_semantics_verify.sql`

O verify deve confirmar `migration_012_count = 1` e `corrected_rules_json_count = 2`.

## Roteiro manual após publicação

- Confirmar `São Paulo` e `Outros estados`; selecionar `Outros estados` e verificar análise manual.
- Confirmar PBT oculto quando nenhuma regra persistida o exigir.
- Testar contato confirmado: deve resultar em análise manual.
- Testar ausência de contato com os demais requisitos favoráveis: pode resultar em análise preliminar, sem garantia de aprovação.
- Testar `Não sei informar`: deve resultar em análise manual.
- Repetir os três testes para suspensão e rodas/pneus.
- Adicionar, remover e reordenar modificações adicionais; verificar catálogo, bloqueio de duplicidades e bloqueio de cadastro de motor.
- Conferir os valores de referência já documentados e a presença única do honorário de R$ 160,00.
- Gerar PDF para resultado viável e análise manual; conferir textos, documentos e ausência de códigos internos.
- Conferir mensagem de WhatsApp, impressão e responsividade em desktop e celular.
- Regressar no serviço de cadastro de motor e confirmar que não houve alteração de comportamento.

Não utilizar dados reais de clientes, não consumir a Simples API e não considerar a homologação concluída sem evidência visual e funcional do proprietário.
