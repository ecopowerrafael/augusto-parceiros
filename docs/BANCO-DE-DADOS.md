# Banco de dados

Não existe banco nesta fase. A configuração futura deverá usar MySQL da Hostinger via `DATABASE_URL` com host `127.0.0.1`.

Entidades previstas: usuário, parceiro, cliente, veículo, serviço, regra de viabilidade, tabela de preço, orçamento, solicitação, documento, link de upload, evento de timeline e histórico de alterações.

Toda entidade de negócio deve carregar o escopo de tenant quando aplicável. Alterações de schema exigem migration, análise de dados existentes, índice/constraint, plano de rollback e deploy progressivo.
