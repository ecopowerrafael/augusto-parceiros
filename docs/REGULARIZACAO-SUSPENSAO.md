# Regularização de suspensão

O serviço `LOWERED_SUSPENSION` foi ampliado para **Regularização de suspensão**, abrangendo rebaixamento, elevação, kits Lift e outras alterações. O fluxo usa o construtor no-code, campos declarativos, regras, cobranças, documentos, mensagens, simulador, PDF e WhatsApp existentes.

Nesta fase os dados do veículo são informados manualmente ou com valores fictícios. Não há consulta real de placa e não há chamada à Simples API.

Motocicletas, caminhões, ônibus, veículos acima de 3.500 kg e categorias sem regra específica seguem para análise manual. Para veículos leves, a resposta `SIM` de conformidade permite análise preliminar; `NÃO` ou `NÃO SEI` não é garantia de regularização e pode exigir adequações, vistoria ou CSV.

Rodas e pneus são uma única modificação comercial. Modificações adicionais são itens distintos do catálogo, com descrição própria e cobrança por item válido. Linhas vazias, duplicadas, inativas e cadastro de motor são rejeitados pelo backend.

Fontes de referência inicial: Resolução CONTRAN nº 916/2022 e alterações, Detran-SP, Poupatempo-SP, SENATRAN e Inmetro quando aplicável. A data e a condição normativa devem ser confirmadas antes de transformar um item em regra definitiva.
