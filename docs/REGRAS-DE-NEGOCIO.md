# Regras de negócio

As regras abaixo são política operacional inicial e precisam de validação antes de uso comercial definitivo.

- Motocicletas: mesma cilindrada = cadastro comum; diferente = bloquear orçamento automático; insuficiente = análise manual.
- Automóveis: mesma potência e cilindrada = cadastro comum; potência inferior ou superior até 10%, inclusive = modificação + inspeção ITL/CSV; superior a 10% = bloquear automático; mesma potência com cilindrada diferente e alteração de combustível = análise manual.
- Caminhões: diferença de potência não bloqueia automaticamente; alterações técnicas vão para análise administrativa; necessidade de ITL/CSV pendente.
- Categorias desconhecidas ficam em análise manual.
- Resultado de viabilidade nunca é garantia de aprovação pelo Detran.
- Dados técnicos ausentes ou inválidos não devem ser inventados.
- Serviços, formulários, cobranças, exigências e regras devem ser configuráveis por versão, sem lógica exclusiva de um serviço no React ou Express.
- Regras `DRAFT` só podem ser testadas no simulador administrativo; não liberam orçamento comercial.
- Cobranças condicionais são avaliadas no backend, deduplicadas por código e nunca somam item sem valor definido.
