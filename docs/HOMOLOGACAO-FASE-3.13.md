# Homologação da Fase 3.13

## Estado

Implementação publicada na `main` em ambiente de testes, versão `0.4.9`. A Migration 010 foi instalada e verificada pelo proprietário na Hostinger; não reimportar a migration nem executar SQL remoto.

## Roteiro do administrador

1. Acessar `/admin` e abrir `Catálogo de modificações`.
2. Criar uma modificação de teste com categoria, descrição, status jurídico `A confirmar`, cobrança e exigência de descrição.
3. Editar a modificação e confirmar nome, orientação, referência, CSV, ECV, autorização prévia e análise manual.
4. Abrir os detalhes e configurar documentos e mensagens.
5. Configurar vínculos de categoria e UF; testar inclusão, remoção, ativação e desativação.
6. Confirmar que o catálogo informa caráter preliminar e não promete homologação legal.
7. Abrir o construtor no-code do serviço `Regularização de suspensão`.
8. Confirmar os 17 campos, a ordem das perguntas, as opções e as condições de visibilidade/obrigatoriedade.
9. Usar o simulador administrativo com a versão DRAFT; não publicar a versão automaticamente.

## Roteiro funcional da suspensão

Testar, em automóvel e caminhonete:

- Rebaixamento, elevação/Kit Lift e outra alteração.
- Suspensão: `Sim`, `Não` e `Não sei`.
- Para `Não sei`, preencher checklist positivo e negativo.
- Incluir rodas e pneus; conferir checklist condicional.
- Adicionar uma e várias modificações distintas.
- Remover e alterar modificações; confirmar recálculo.
- Tentar duplicar uma modificação e selecionar cadastro de motor; ambos devem ser impedidos.
- Testar modificação inativa, categoria incompatível, UF incompatível e descrição obrigatória ausente.
- Testar motocicleta, caminhão, ônibus e categoria sem regra específica; não devem receber aprovação automática indevida.
- Alterar respostas depois de preencher campos que ficam ocultos; valores ocultos não podem interferir no resultado.

## Valores de referência

| Cenário | Total |
| --- | ---: |
| Suspensão + Mercosul | R$ 755,80 |
| Suspensão + placa antiga | R$ 975,80 |
| Suspensão + rodas/pneus + Mercosul | R$ 1.055,80 |
| Suspensão + rodas/pneus + placa antiga | R$ 1.275,80 |
| Suspensão + uma modificação adicional + Mercosul | R$ 1.055,80 |
| Suspensão + duas modificações adicionais + Mercosul | R$ 1.355,80 |
| Suspensão + rodas/pneus + duas adicionais + placa antiga | R$ 1.875,80 |

O honorário deve aparecer uma única vez: R$ 160,00. Quando a comissão estiver configurada como honorário integral, o parceiro deve receber R$ 160,00 independentemente da quantidade de modificações.

## Segurança e publicação

- Confirmar que parceiro/cliente não acessam configurações DRAFT como serviços publicados.
- Confirmar proteção das rotas administrativas e isolamento de permissões.
- Confirmar que documentos e mensagens configurados aparecem apenas quando aplicáveis.
- Confirmar responsividade em desktop e celular.
- Não publicar comercialmente o serviço de suspensão antes da aprovação administrativa.
- Não consumir créditos da Simples API; esta fase não faz chamadas reais.

## Registro do teste manual

Preencher pelo proprietário: data, usuário/perfil, cenário, resultado observado, divergência, captura de tela e decisão. A ausência de teste visual automatizado não é evidência de aprovação; a homologação funcional permanece pendente até esse registro humano.

Não iniciar a Fase 4.
