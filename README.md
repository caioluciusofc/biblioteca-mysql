Sistema de Biblioteca MySQL

Projeto acadêmico de banco de dados para gerenciar o acervo, os leitores, as reservas, os empréstimos, as devoluções e as multas de uma biblioteca.

O projeto reúne 14 tabelas, 24 consultas SQL, 3 triggers e 3 procedures**. O modelo separa a obra, a edição e o exemplar físico, permitindo controlar a disponibilidade de cada cópia.

Regras de empréstimo e devolução

Operação Comportamento do banco

Registrar empréstimo Bloqueia exemplares indisponíveis e leitores com multa em aberto. Se o empréstimo for aceito, marca o exemplar como emprestado.
Registrar devolução Marca o exemplar como disponível. Se houver atraso, gera uma multa de R$ 1,00 por dia.
Pagar multa Registra a data de pagamento da multa em aberto.

Como executar

1. Conecte-se a um servidor MySQL pelo MySQL Workbench.
2. Abra e execute [`biblioteca.sql`](biblioteca.sql) em um ambiente de teste. O script cria as tabelas e rotinas, carrega os dados de exemplo e executa as consultas.
3. Abra [`testes.sql`](testes.sql) e execute os exemplos separadamente. Para demonstrar o bloqueio por multa em aberto, rode a chamada comentada antes de pagar a multa do leitor usado no teste.

As consultas incluem `JOIN`, `GROUP BY`, `HAVING`, subconsultas e `UNION`.
