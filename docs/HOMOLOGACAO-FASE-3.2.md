# Homologação da Fase 3.2

Este roteiro registra a validação do construtor no-code e do avaliador declarativo em ambiente de homologação. Ele não substitui a validação jurídica ou a aprovação do Detran. Os dados abaixo são fictícios e não devem conter dados reais de clientes.

## Estado da publicação

- Ambiente: Hostinger, `APP_ENV=staging`.
- Versão esperada: `0.3.0`.
- URL: `https://docmotor.online/`.
- Código: branch `main`.
- Migrations 001, 002 e 003: confirmadas pelo proprietário no banco remoto; não executar novamente.
- Serviço inicial: `Cadastro de Motor`, mantido em `DRAFT`.
- Integração Simples API: fora do escopo; as fontes externas do simulador são declarativas/simuladas.

## Pré-condições

1. O proprietário deve entrar em `/login` com uma sessão administrativa autorizada.
2. Confirmar que `/api/health` responde `status=ok` e `version=0.3.0` antes do teste.
3. Usar apenas placas, nomes e contatos fictícios.
4. Não publicar uma versão nem alterar o serviço original durante a homologação sem registrar a decisão.
5. Manter a aba do navegador sem dados de um cliente real; a tela administrativa é protegida e não deve ser compartilhada em capturas públicas.

## Cenários do serviço Cadastro de Motor

No simulador do serviço inicial, preencher somente os campos necessários para cada linha. Quando não indicado, usar potência/cilindrada compatíveis e combustível igual entre veículo-alvo e motor de origem.

| ID | Entrada principal | Resultado esperado | Total esperado |
| --- | --- | --- | ---: |
| M01 | Nota fiscal `Sim`; placa-alvo Mercosul; sem alteração de potência | Viabilidade preliminar sem adicional de nota ou Mercosul | R$ 755,80 |
| M02 | Nota fiscal `Não`; placa-alvo Mercosul; sem alteração de potência | Adicional de motor sem nota | R$ 1.055,80 |
| M03 | Nota fiscal `Não`; placa-alvo antiga; sem alteração de potência | Adicionais de motor sem nota e autorização Mercosul | R$ 1.275,80 |
| M04 | Nota fiscal `Não`; placa antiga; aumento de potência de 5% | Modificação + inspeção; CSV sem preço definido exige revisão manual | R$ 1.575,80 + CSV sem valor |
| M05 | Aumento de potência exatamente 10% | Dentro do limite preliminar; não bloquear automaticamente; incluir itens de alteração/CSV | Base + itens configurados |
| M06 | Aumento de potência de 10,01% | Fora do critério; bloquear orçamento automático | Não calcular como orçamento aprovado |
| M07 | Redução de potência, por exemplo `-5%` | Análise manual com modificação/inspeção conforme regra declarativa | Sem garantia de aprovação |
| M08 | Potência do alvo ou do motor ausente | Análise manual; não assumir potência zero | Não concluir viabilidade |
| M09 | Placa doadora antiga e placa-alvo Mercosul | Não cobrar Mercosul com base apenas na placa doadora | Conforme entrada do alvo |
| M10 | Combustível do alvo diferente do motor | Análise manual por alteração de combustível | Não concluir viabilidade |
| M11 | Aumento de `10,001%` | Bloquear; não arredondar para `10%` | Não calcular como limite |
| M12 | Alternar placa doadora ↔ preenchimento manual | Limpar/ignorar o valor da fonte que deixou de estar selecionada | Sem dados residuais |

Para M05 e M11, registrar o valor exibido pelo simulador com pelo menos três casas decimais ou o payload equivalente. A regra deve comparar o valor numérico real; arredondamento visual não pode transformar `10,001%` em `10%`.

### Evidência mínima por cenário

Registrar em uma planilha local ou no relatório de homologação:

- data e hora;
- identificador do cenário;
- entradas utilizadas;
- resultado de viabilidade;
- itens incluídos e itens ausentes;
- total e itens sem preço;
- observação sobre revisão manual/bloqueio;
- resultado: aprovado, reprovado ou inconclusivo.

Não registrar senha, cookie, token CSRF ou documento pessoal.

## Segundo serviço no-code

O proprietário deve criar exclusivamente pela interface administrativa um segundo serviço demonstrativo de suspensão, por exemplo:

1. Duplicar ou criar um serviço com nome e slug próprios, sem substituir `Cadastro de Motor`.
2. Criar uma versão `DRAFT`.
3. Adicionar ao menos duas seções e campos compatíveis com o serviço, incluindo uma seleção ou resposta sim/não.
4. Configurar pelo menos uma cobrança e confirmar que o valor fica associado à versão correta.
5. Configurar uma condição de visibilidade ou uma regra declarativa.
6. Configurar ao menos um documento e uma mensagem de orientação.
7. Executar o simulador com entrada válida e entrada que acione a condição.
8. Confirmar que o serviço original continua inalterado e que a nova versão permanece em rascunho.
9. Conferir no histórico administrativo os eventos de criação/alteração, sem expor dados sensíveis.

## Checklist de aceite

- [ ] Acesso administrativo realizado com sessão real.
- [ ] Serviço original localizado e preservado.
- [ ] M01–M12 executados e evidências registradas.
- [ ] Segundo serviço criado sem SQL manual.
- [ ] Campos, opção, cobrança, condição, regra, documento e mensagem testados.
- [ ] Simulador respondeu sem erro de interface.
- [ ] Nenhuma versão foi publicada sem decisão explícita.
- [ ] Nenhum dado real de cliente foi usado.
- [ ] Conferência visual manual concluída pelo proprietário.

## Limites desta homologação

Os resultados são uma aplicação da política operacional preliminar cadastrada e não representam garantia de aprovação pelo Detran. A consulta veicular real, orçamento definitivo, PDF, documentos de clientes, financeiro e Fase 4 permanecem fora desta etapa.
