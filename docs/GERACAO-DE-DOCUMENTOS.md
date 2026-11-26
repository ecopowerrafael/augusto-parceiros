# Geração de resultados e documentos

## Escopo da Fase 3.8

O simulador administrativo recebe um resultado visual reutilizável, sem exibir JSON bruto como apresentação principal. O resultado é derivado exclusivamente da resposta validada pelo avaliador declarativo do backend.

Todos os documentos desta fase são demonstrações e exibem `SIMULAÇÃO — SEM VALIDADE COMERCIAL`. Não são orçamentos persistidos, não recebem numeração comercial e não geram comissões.

## Arquitetura

- `ServiceResultView` apresenta situação, dados analisados, cobranças, subtotal conhecido, documentos e diagnóstico técnico recolhido.
- `generateSimulationPdf` usa `pdf-lib`, sem Chromium, APIs pagas ou serviço externo. Gera A4 em texto selecionável e usa centavos recebidos do backend.
- Impressão usa a mesma representação visual e uma folha de estilo de impressão A4.
- Download e visualização geram o PDF a partir do mesmo modelo de resultado.
- Web Share API compartilha o arquivo quando `navigator.canShare({ files })` estiver disponível. Caso contrário, o PDF é baixado e o WhatsApp é aberto com orientação para anexá-lo.

## Privacidade e autorização

O componente está atualmente acessível no construtor administrativo protegido. O diagnóstico técnico fica recolhido e não deve ser reutilizado em documentos de cliente ou parceiro sem filtragem de dados internos. UUIDs, expressões declarativas, margens e comissões não são incluídos no PDF.

Contatos comerciais por perfil, códigos públicos persistentes e orçamentos comerciais numerados ainda dependem dos módulos futuros de orçamento e operação. A Fase 3.8 não inventa esses dados.

## Limitações homologadas

- O compartilhamento de arquivo depende do navegador e do sistema operacional.
- No desktop sem Web Share, o usuário deve anexar manualmente o PDF baixado.
- O PDF atual cobre a demonstração do simulador; cabeçalho comercial completo, contato por emissor e numeração definitiva serão ligados aos registros persistidos na Fase 6.
- Validação visual final em Hostinger permanece manual quando o navegador automatizado não estiver disponível.

## Critérios de teste

Os testes verificam regras declarativas por categoria, modo manual sem placa doadora, filtragem de ações vazias, cenários de potência/combustível e geração de um PDF real com assinatura `%PDF-`.
