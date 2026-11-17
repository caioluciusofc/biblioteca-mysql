DROP DATABASE IF EXISTS biblioteca; -- apaga o banco antigo, se existir, para recomecar do zero
CREATE DATABASE biblioteca CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; -- cria o banco com suporte a acentos
USE biblioteca; -- seleciona o banco para os proximos comandos

 CREATE TABLE categoria ( -- tabela das categorias das obras
 id_categoria INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria numerica automatica
 nome_categoria VARCHAR(45) NOT NULL UNIQUE, -- nome obrigatorio e sem repeticao
 descricao_categoria VARCHAR(255) -- descricao opcional da categoria
); -- fim da tabela categoria

CREATE TABLE editora ( -- tabela das editoras
 id_editora INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 nome_editora VARCHAR(100) NOT NULL, -- nome obrigatorio da editora
 telefone_editora VARCHAR(20) -- telefone opcional
); -- fim da tabela editora

CREATE TABLE cargo ( -- tabela dos cargos dos funcionarios
 id_cargo INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 nome_cargo VARCHAR(45) NOT NULL UNIQUE -- nome do cargo, obrigatorio e unico
); -- fim da tabela cargo

CREATE TABLE leitor ( -- tabela dos leitores da biblioteca
 id_leitor INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 nome_leitor VARCHAR(100) NOT NULL, -- nome obrigatorio do leitor
 telefone_leitor VARCHAR(20), -- telefone opcional
 endereco_leitor VARCHAR(150) NOT NULL -- endereco obrigatorio
); -- fim da tabela leitor

CREATE TABLE obra ( -- tabela das obras (o titulo em si)
 id_obra INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 nome_obra VARCHAR(150) NOT NULL, -- nome obrigatorio da obra
 id_categoria INT NOT NULL, -- cada obra pertence a uma categoria
 CONSTRAINT fk_obra_categoria FOREIGN KEY (id_categoria) -- define a chave estrangeira para categoria
 REFERENCES categoria (id_categoria) -- aponta para a chave primaria de categoria
); -- fim da tabela obra

CREATE TABLE autoria ( -- entidade associativa que liga obra e autor
 id_autoria INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 id_obra INT NOT NULL, -- obra a que a autoria pertence
 CONSTRAINT fk_autoria_obra FOREIGN KEY (id_obra) -- define a chave estrangeira para obra
 REFERENCES obra (id_obra) -- aponta para a chave primaria de obra
); -- fim da tabela autoria

CREATE TABLE autor ( -- tabela dos autores
 id_autor INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 nome_autor VARCHAR(100) NOT NULL, -- nome obrigatorio do autor
 nacionalidade_autor VARCHAR(45), -- nacionalidade opcional
 id_autoria INT NOT NULL, -- autoria da qual o autor participa
 CONSTRAINT fk_autor_autoria FOREIGN KEY (id_autoria) -- define a chave estrangeira para autoria
 REFERENCES autoria (id_autoria) -- aponta para a chave primaria de autoria
); -- fim da tabela autor

CREATE TABLE livro ( -- tabela dos livros (edicoes de uma obra)
 id_livro INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 nome_livro VARCHAR(150) NOT NULL, -- nome obrigatorio da edicao
 num_paginas INT, -- numero de paginas (opcional)
 isbn VARCHAR(13) NOT NULL UNIQUE, -- ISBN obrigatorio e sem repeticao
 id_obra INT NOT NULL, -- obra a que a edicao pertence
 id_editora INT NOT NULL, -- editora que publicou o livro
 CONSTRAINT fk_livro_obra FOREIGN KEY (id_obra) -- chave estrangeira para obra
 REFERENCES obra (id_obra), -- aponta para obra
 CONSTRAINT fk_livro_editora FOREIGN KEY (id_editora) -- chave estrangeira para editora
 REFERENCES editora (id_editora) -- aponta para editora
); -- fim da tabela livro

CREATE TABLE funcionario ( -- tabela dos funcionarios
 id_funcionario INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 nome_funcionario VARCHAR(100) NOT NULL, -- nome obrigatorio
 email_funcionario VARCHAR(100), -- e-mail opcional
 cpf_funcionario CHAR(11) NOT NULL UNIQUE, -- CPF com 11 digitos, obrigatorio e unico
 id_cargo INT NOT NULL, -- cargo ocupado pelo funcionario
 CONSTRAINT fk_funcionario_cargo FOREIGN KEY (id_cargo) -- chave estrangeira para cargo
 REFERENCES cargo (id_cargo) -- aponta para cargo
); -- fim da tabela funcionario

CREATE TABLE exemplar ( -- tabela das copias fisicas dos livros
 id_exemplar INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 data_aquisicao_exemplar DATE NOT NULL, -- data em que a copia foi adquirida
 situacao_exemplar ENUM('Disponivel','Emprestado','Danificado') -- so aceita um destes tres valores
 NOT NULL DEFAULT 'Disponivel', -- obrigatorio; se omitido, assume Disponivel
 id_livro INT NOT NULL, -- livro (edicao) do qual a copia faz parte
 CONSTRAINT fk_exemplar_livro FOREIGN KEY (id_livro) -- chave estrangeira para livro
 REFERENCES livro (id_livro) -- aponta para livro
); -- fim da tabela exemplar

CREATE TABLE reserva ( -- tabela das reservas de exemplares
 id_reserva INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 data_reserva DATE NOT NULL, -- data em que a reserva foi feita
 situacao_reserva ENUM('Aguardando','Atendida','Cancelada') -- so aceita um destes tres valores
 NOT NULL DEFAULT 'Aguardando', -- obrigatorio; se omitido, assume Aguardando
 id_exemplar INT NOT NULL, -- exemplar reservado
 id_leitor INT NOT NULL, -- leitor que fez a reserva
 CONSTRAINT fk_reserva_exemplar FOREIGN KEY (id_exemplar) -- chave estrangeira para exemplar
 REFERENCES exemplar (id_exemplar), -- aponta para exemplar
 CONSTRAINT fk_reserva_leitor FOREIGN KEY (id_leitor) -- chave estrangeira para leitor
 REFERENCES leitor (id_leitor) -- aponta para leitor
); -- fim da tabela reserva

CREATE TABLE emprestimo ( -- tabela dos emprestimos
 id_emprestimo INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 data_emprestimo DATE NOT NULL, -- data em que o exemplar saiu
 data_devolucao DATE NOT NULL, -- prazo: data em que o exemplar deve voltar
 id_exemplar INT NOT NULL, -- exemplar emprestado
 id_leitor INT NOT NULL, -- leitor que pegou o exemplar
 CONSTRAINT fk_emprestimo_exemplar FOREIGN KEY (id_exemplar) -- chave estrangeira para exemplar
 REFERENCES exemplar (id_exemplar), -- aponta para exemplar
 CONSTRAINT fk_emprestimo_leitor FOREIGN KEY (id_leitor) -- chave estrangeira para leitor
 REFERENCES leitor (id_leitor), -- aponta para leitor
 CONSTRAINT ck_emprestimo_datas CHECK (data_devolucao >= data_emprestimo) -- o prazo nao pode ser anterior ao emprestimo
); -- fim da tabela emprestimo

CREATE TABLE devolucao ( -- tabela das devolucoes
 id_devolucao INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 data_devolucao DATE NOT NULL, -- data real em que o exemplar voltou
 id_emprestimo INT NOT NULL UNIQUE, -- emprestimo devolvido (UNIQUE: no maximo uma devolucao por emprestimo)
 id_funcionario INT NOT NULL, -- funcionario que registrou a devolucao
 CONSTRAINT fk_devolucao_emprestimo FOREIGN KEY (id_emprestimo) -- chave estrangeira para emprestimo
 REFERENCES emprestimo (id_emprestimo), -- aponta para emprestimo
 CONSTRAINT fk_devolucao_funcionario FOREIGN KEY (id_funcionario) -- chave estrangeira para funcionario
 REFERENCES funcionario (id_funcionario) -- aponta para funcionario
); -- fim da tabela devolucao

CREATE TABLE multa ( -- tabela das multas por atraso
 id_multa INT AUTO_INCREMENT PRIMARY KEY, -- chave primaria automatica
 dias_atraso INT NOT NULL, -- quantidade de dias de atraso
 valor DECIMAL(8,2) NOT NULL, -- valor da multa com 2 casas decimais
 data_pagamento DATE NULL, -- NULL = multa em aberto
 id_devolucao INT NOT NULL UNIQUE, -- devolucao que gerou a multa (no maximo uma por devolucao)
 CONSTRAINT fk_multa_devolucao FOREIGN KEY (id_devolucao) -- chave estrangeira para devolucao
 REFERENCES devolucao (id_devolucao) -- aponta para devolucao
); -- fim da tabela multa

DELIMITER $$

CREATE TRIGGER trg_valida_emprestimo -- trigger que valida o emprestimo antes de gravar
BEFORE INSERT ON emprestimo -- dispara antes de inserir na tabela emprestimo
FOR EACH ROW -- executa para cada linha inserida
BEGIN -- inicio do bloco da trigger
 DECLARE v_situacao VARCHAR(20); -- variavel para guardar a situacao do exemplar
 DECLARE v_multas_abertas INT; -- variavel para contar multas em aberto do leitor
 SELECT situacao_exemplar INTO v_situacao -- le a situacao do exemplar e guarda na variavel
 FROM exemplar WHERE id_exemplar = NEW.id_exemplar; -- exemplar que esta sendo emprestado (NEW = nova linha)
 IF v_situacao <> 'Disponivel' THEN -- se o exemplar nao estiver disponivel
 SIGNAL SQLSTATE '45000' -- gera um erro personalizado e cancela o insert
 SET MESSAGE_TEXT = 'Exemplar indisponivel para emprestimo.'; -- mensagem mostrada ao usuario
 END IF; -- fim do primeiro teste
 SELECT COUNT(*) INTO v_multas_abertas -- conta as multas nao pagas do leitor
 FROM multa m -- parte da tabela multa
 JOIN devolucao d ON d.id_devolucao = m.id_devolucao -- liga a multa a sua devolucao
 JOIN emprestimo e ON e.id_emprestimo = d.id_emprestimo -- liga a devolucao ao emprestimo
 WHERE e.id_leitor = NEW.id_leitor AND m.data_pagamento IS NULL; -- so o leitor atual e multas sem pagamento
 IF v_multas_abertas > 0 THEN -- se existir alguma multa em aberto
 SIGNAL SQLSTATE '45000' -- gera erro e cancela o insert
 SET MESSAGE_TEXT = 'Leitor possui multa em aberto.'; -- mensagem mostrada ao usuario
 END IF; -- fim do segundo teste
END$$ -- fim da trigger

CREATE TRIGGER trg_exemplar_emprestado -- trigger que marca o exemplar como emprestado
AFTER INSERT ON emprestimo -- dispara depois de inserir um emprestimo
FOR EACH ROW -- executa para cada linha inserida
BEGIN -- inicio do bloco
 UPDATE exemplar -- atualiza a tabela exemplar
 SET situacao_exemplar = 'Emprestado' -- muda a situacao para Emprestado
 WHERE id_exemplar = NEW.id_exemplar; -- somente o exemplar do emprestimo novo
END$$ -- fim da trigger

CREATE TRIGGER trg_devolucao -- trigger que trata a devolucao e gera a multa
AFTER INSERT ON devolucao -- dispara depois de inserir uma devolucao
FOR EACH ROW -- executa para cada linha inserida
BEGIN -- inicio do bloco
 DECLARE v_exemplar INT; -- variavel para o id do exemplar devolvido
 DECLARE v_prazo DATE; -- variavel para o prazo original do emprestimo
 DECLARE v_dias INT; -- variavel para os dias de atraso
 SELECT id_exemplar, data_devolucao INTO v_exemplar, v_prazo -- busca exemplar e prazo do emprestimo
 FROM emprestimo WHERE id_emprestimo = NEW.id_emprestimo; -- emprestimo que esta sendo devolvido
 UPDATE exemplar -- atualiza a tabela exemplar
 SET situacao_exemplar = 'Disponivel' -- o exemplar volta a ficar disponivel
 WHERE id_exemplar = v_exemplar; -- somente o exemplar devolvido
 SET v_dias = DATEDIFF(NEW.data_devolucao, v_prazo); -- dias entre a devolucao real e o prazo
 IF v_dias > 0 THEN -- se devolveu depois do prazo
 INSERT INTO multa (dias_atraso, valor, id_devolucao) -- cria a multa
 VALUES (v_dias, v_dias * 1.00, NEW.id_devolucao); -- valor = R$ 1,00 por dia de atraso
 END IF; -- fim do teste de atraso
END$$ -- fim da trigger

CREATE PROCEDURE sp_registrar_emprestimo ( -- procedure que registra um emprestimo
 IN p_id_exemplar INT, -- parametro: exemplar a emprestar
 IN p_id_leitor INT, -- parametro: leitor que vai pegar o exemplar
 IN p_prazo_dias INT -- parametro: quantidade de dias de prazo
) -- fim dos parametros
BEGIN -- inicio do bloco
 INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) -- insere o emprestimo
 VALUES (CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL p_prazo_dias DAY), -- data de hoje e prazo = hoje + dias
 p_id_exemplar, p_id_leitor); -- exemplar e leitor informados
 SELECT LAST_INSERT_ID() AS id_emprestimo_criado, -- mostra o id do emprestimo criado
 DATE_ADD(CURRENT_DATE, INTERVAL p_prazo_dias DAY) AS devolver_ate; -- mostra ate quando devolver
END$$ -- fim da procedure

CREATE PROCEDURE sp_registrar_devolucao ( -- procedure que registra uma devolucao
 IN p_id_emprestimo INT, -- parametro: emprestimo sendo devolvido
 IN p_id_funcionario INT -- parametro: funcionario que registra
) -- fim dos parametros
BEGIN -- inicio do bloco
 INSERT INTO devolucao (data_devolucao, id_emprestimo, id_funcionario) -- insere a devolucao
 VALUES (CURRENT_DATE, p_id_emprestimo, p_id_funcionario); -- data de hoje, emprestimo e funcionario
 SELECT d.id_devolucao, d.data_devolucao, -- mostra id e data da devolucao
 COALESCE(m.dias_atraso, 0) AS dias_atraso, -- dias de atraso (0 se nao houve multa)
 COALESCE(m.valor, 0) AS multa -- valor da multa (0 se nao houve)
 FROM devolucao d -- parte da tabela devolucao
 LEFT JOIN multa m ON m.id_devolucao = d.id_devolucao -- junta a multa, se existir
 WHERE d.id_emprestimo = p_id_emprestimo; -- somente a devolucao deste emprestimo
END$$ -- fim da procedure

CREATE PROCEDURE sp_pagar_multa ( -- procedure que registra o pagamento de uma multa
 IN p_id_multa INT -- parametro: multa a ser paga
) -- fim dos parametros
BEGIN -- inicio do bloco
 UPDATE multa -- atualiza a tabela multa
 SET data_pagamento = CURRENT_DATE -- grava a data de hoje como pagamento
 WHERE id_multa = p_id_multa AND data_pagamento IS NULL; -- so se ainda estiver em aberto
 SELECT id_multa, valor, data_pagamento -- mostra o resultado
 FROM multa WHERE id_multa = p_id_multa; -- da multa informada
END$$ -- fim da procedure

DELIMITER ;

INSERT INTO categoria (nome_categoria, descricao_categoria) VALUES -- insere as categorias
('Romance', 'Narrativas de ficcao em prosa'), -- categoria 1
('Tecnologia', 'Computacao, sistemas e engenharia'), -- categoria 2
('Direito', 'Doutrina e legislacao'), -- categoria 3
('Historia', 'Historia geral e do Brasil'), -- categoria 4
('Ficcao Cientifica', 'Ficcao baseada em ciencia e futuro'); -- categoria 5

INSERT INTO editora (nome_editora, telefone_editora) VALUES -- insere as editoras
('Companhia das Letras', '1137073500'), -- editora 1
('Pearson', '1121788686'), -- editora 2
('Saraiva', '1136133000'), -- editora 3
('Aleph', '1137430770'); -- editora 4

INSERT INTO cargo (nome_cargo) VALUES -- insere os cargos
('Bibliotecario'), ('Auxiliar de Biblioteca'), ('Atendente'); -- cargos 1, 2 e 3

INSERT INTO leitor (nome_leitor, telefone_leitor, endereco_leitor) VALUES -- insere os leitores
('Ana Souza', '61991110001', 'QS 10 Conjunto A Casa 5, Aguas Claras, Brasilia-DF'), -- leitor 1
('Bruno Lima', '61991110002', 'Rua 12 Lote 8, Taguatinga, Brasilia-DF'), -- leitor 2
('Carla Mendes', '61991110003', 'SQN 210 Bloco C Apto 302, Asa Norte, Brasilia-DF'), -- leitor 3
('Diego Santos', '61991110004', 'Quadra 3 Casa 14, Valparaiso de Goias-GO'), -- leitor 4
('Elisa Rocha', '61991110005', 'QNM 18 Conjunto F Casa 2, Ceilandia, Brasilia-DF'), -- leitor 5
('Felipe Araujo', '61991110006', 'Rua 5 Casa 30, Samambaia, Brasilia-DF'); -- leitor 6

INSERT INTO obra (nome_obra, id_categoria) VALUES -- insere as obras
('Dom Casmurro', 1), -- obra 1 (Romance)
('Sistemas de Banco de Dados', 2), -- obra 2 (Tecnologia)
('1984', 5), -- obra 3 (Ficcao Cientifica)
('Direito Constitucional', 3), -- obra 4 (Direito)
('Sapiens: Uma Breve Historia da Humanidade', 4), -- obra 5 (Historia)
('Engenharia de Software', 2); -- obra 6 (Tecnologia)

INSERT INTO autoria (id_obra) VALUES (1), (2), (3), (4), (5), (6); -- cria uma autoria para cada obra

INSERT INTO autor (nome_autor, nacionalidade_autor, id_autoria) VALUES -- insere os autores
('Machado de Assis', 'Brasileira', 1), -- autor da autoria 1
('Ramez Elmasri', 'Egipcia', 2), -- primeiro autor da autoria 2
('Shamkant Navathe', 'Indiana', 2), -- segundo autor da autoria 2
('George Orwell', 'Britanica', 3), -- autor da autoria 3
('Alexandre de Moraes', 'Brasileira', 4), -- autor da autoria 4
('Yuval Noah Harari', 'Israelense', 5), -- autor da autoria 5
('Ian Sommerville', 'Britanica', 6); -- autor da autoria 6

INSERT INTO livro (nome_livro, num_paginas, isbn, id_obra, id_editora) VALUES -- insere os livros (edicoes)
('Dom Casmurro', 256, '9788535910001', 1, 1), -- livro 1
('Sistemas de Banco de Dados - 6a edicao', 788, '9788579360002', 2, 2), -- livro 2
('Sistemas de Banco de Dados - 7a edicao', 952, '9788543025003', 2, 2), -- livro 3
('1984', 416, '9788535914004', 3, 1), -- livro 4
('Direito Constitucional - 39a edicao', 1024, '9788597025005', 4, 3), -- livro 5
('Sapiens', 472, '9788525432006', 5, 1), -- livro 6
('Engenharia de Software - 10a edicao', 768, '9788543024007', 6, 2); -- livro 7

INSERT INTO funcionario (nome_funcionario, email_funcionario, cpf_funcionario, id_cargo) VALUES -- insere os funcionarios
('Marta Oliveira', 'marta@biblioteca.edu.br', '11122233344', 1), -- funcionaria 1 (Bibliotecario)
('Joao Pereira', 'joao@biblioteca.edu.br', '22233344455', 2), -- funcionario 2 (Auxiliar)
('Lucas Ferreira', 'lucas@biblioteca.edu.br', '33344455566', 3); -- funcionario 3 (Atendente)

INSERT INTO exemplar (data_aquisicao_exemplar, situacao_exemplar, id_livro) VALUES -- insere os exemplares
('2024-02-10', 'Disponivel', 1), -- exemplar 1 do livro 1
('2024-02-10', 'Disponivel', 1), -- exemplar 2 do livro 1
('2023-08-15', 'Disponivel', 2), -- exemplar 3 do livro 2
('2023-08-15', 'Disponivel', 2), -- exemplar 4 do livro 2
('2025-03-01', 'Disponivel', 3), -- exemplar 5 do livro 3
('2024-05-20', 'Disponivel', 4), -- exemplar 6 do livro 4
('2024-05-20', 'Disponivel', 4), -- exemplar 7 do livro 4
('2025-01-12', 'Disponivel', 5), -- exemplar 8 do livro 5
('2025-06-30', 'Disponivel', 6), -- exemplar 9 do livro 6
('2022-09-05', 'Danificado', 7); -- exemplar 10 do livro 7 (danificado)

INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-09-01', '2026-09-15', 1, 1); -- emprestimo 1: Ana pega o exemplar 1
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-09-05', '2026-09-19', 3, 2); -- emprestimo 2: Bruno pega o exemplar 3
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-09-10', '2026-10-10', 5, 3); -- emprestimo 3: Carla pega o exemplar 5
INSERT INTO devolucao (data_devolucao, id_emprestimo, id_funcionario) VALUES ('2026-09-14', 1, 3); -- devolucao do emprestimo 1 no prazo (sem multa)
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-09-20', '2026-10-04', 1, 4); -- emprestimo 4: Diego pega o exemplar 1
INSERT INTO devolucao (data_devolucao, id_emprestimo, id_funcionario) VALUES ('2026-09-24', 2, 3); -- devolucao do emprestimo 2 com 5 dias de atraso (gera multa 1)
UPDATE multa SET data_pagamento = '2026-09-25' WHERE id_multa = 1; -- Bruno paga a multa 1
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-10-01', '2026-10-15', 6, 1); -- emprestimo 5: Ana pega o exemplar 6
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-10-05', '2026-10-19', 8, 5); -- emprestimo 6: Elisa pega o exemplar 8
INSERT INTO devolucao (data_devolucao, id_emprestimo, id_funcionario) VALUES ('2026-10-08', 3, 2); -- devolucao do emprestimo 3 no prazo
INSERT INTO devolucao (data_devolucao, id_emprestimo, id_funcionario) VALUES ('2026-10-15', 5, 2); -- devolucao do emprestimo 5 no prazo
INSERT INTO devolucao (data_devolucao, id_emprestimo, id_funcionario) VALUES ('2026-10-16', 4, 3); -- devolucao do emprestimo 4 com 12 dias de atraso (multa 2, em aberto)
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-10-20', '2026-11-03', 3, 6); -- emprestimo 7: Felipe pega o exemplar 3
INSERT INTO devolucao (data_devolucao, id_emprestimo, id_funcionario) VALUES ('2026-10-22', 6, 1); -- devolucao do emprestimo 6 com 3 dias de atraso (multa 3, em aberto)
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-10-25', '2026-11-08', 2, 1); -- emprestimo 8: Ana pega o exemplar 2 (ficara em aberto)
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-11-02', '2026-11-16', 9, 2); -- emprestimo 9: Bruno pega o exemplar 9
INSERT INTO emprestimo (data_emprestimo, data_devolucao, id_exemplar, id_leitor) VALUES ('2026-11-05', '2026-11-19', 6, 3); -- emprestimo 10: Carla pega o exemplar 6

INSERT INTO reserva (data_reserva, situacao_reserva, id_exemplar, id_leitor) VALUES -- insere as reservas
('2026-09-08', 'Atendida', 3, 4), -- reserva 1: Diego, ja atendida
('2026-10-02', 'Cancelada', 6, 6), -- reserva 2: Felipe, cancelada
('2026-10-28', 'Aguardando', 3, 4), -- reserva 3: Diego, aguardando
('2026-11-04', 'Aguardando', 2, 5); -- reserva 4: Elisa, aguardando


USE biblioteca; -- garante que o banco correto esta selecionado

-- 4.1 Consultas basicas
-- Q1
SELECT * FROM obra; -- lista todas as colunas de todas as obras
-- Q2
SELECT nome_leitor, telefone_leitor FROM leitor; -- lista nome e telefone dos leitores
-- Q3
SELECT nome_categoria, descricao_categoria FROM categoria; -- lista nome e descricao das categorias
-- Q4
SELECT nome_autor, nacionalidade_autor FROM autor; -- lista nome e nacionalidade dos autores
-- Q5
SELECT nome_livro, isbn, num_paginas FROM livro; -- lista nome, ISBN e paginas dos livros

-- 4.2 Consultas intermediarias
-- Q6 DISTINCT
SELECT DISTINCT nacionalidade_autor FROM autor; -- nacionalidades sem repeticao
-- Q7 coluna calculada (*)
SELECT id_multa, valor, valor * 1.10 AS valor_com_acrescimo FROM multa; -- mostra a multa com 10% de acrescimo
-- Q8 coluna calculada (-)
SELECT id_emprestimo, data_emprestimo, data_devolucao, -- mostra id e datas do emprestimo
 DATEDIFF(data_devolucao, data_emprestimo) AS prazo_em_dias -- calcula o prazo em dias
FROM emprestimo; -- da tabela emprestimo
-- Q9 WHERE com >
SELECT nome_livro, num_paginas FROM livro WHERE num_paginas > 500; -- livros com mais de 500 paginas
-- Q10 AND e OR
SELECT id_exemplar, id_livro, situacao_exemplar -- colunas exibidas
FROM exemplar -- da tabela exemplar
WHERE situacao_exemplar = 'Disponivel' AND (id_livro = 1 OR id_livro = 2); -- disponiveis dos livros 1 ou 2
-- Q11 NOT
SELECT id_exemplar, situacao_exemplar FROM exemplar -- colunas exibidas da tabela exemplar
WHERE NOT situacao_exemplar = 'Disponivel'; -- exemplares que nao estao disponiveis
-- Q12 SUM, AVG, MAX, MIN
SELECT SUM(valor) AS total_multas, AVG(valor) AS media_multa, -- soma e media das multas
 MAX(valor) AS maior_multa, MIN(valor) AS menor_multa -- maior e menor multa
FROM multa; -- da tabela multa
-- Q13 COUNT
SELECT COUNT(*) AS multas_em_aberto FROM multa WHERE data_pagamento IS NULL; -- conta as multas sem pagamento
-- Q14 LIKE
SELECT nome_obra FROM obra WHERE nome_obra LIKE '%Banco%'; -- obras cujo nome contem "Banco"
-- Q15 BETWEEN
SELECT id_emprestimo, data_emprestimo FROM emprestimo -- colunas exibidas da tabela emprestimo
WHERE data_emprestimo BETWEEN '2026-09-01' AND '2026-09-30'; -- emprestimos feitos em setembro de 2026
-- Q16 IN
SELECT nome_autor, nacionalidade_autor FROM autor -- colunas exibidas da tabela autor
WHERE nacionalidade_autor IN ('Brasileira', 'Britanica'); -- autores brasileiros ou britanicos
-- Q17 JOIN e ORDER BY
SELECT l.nome_livro, o.nome_obra, e.nome_editora, c.nome_categoria -- colunas de quatro tabelas
FROM livro l -- parte da tabela livro
JOIN obra o ON o.id_obra = l.id_obra -- junta com a obra do livro
JOIN editora e ON e.id_editora = l.id_editora -- junta com a editora do livro
JOIN categoria c ON c.id_categoria = o.id_categoria -- junta com a categoria da obra
ORDER BY o.nome_obra; -- ordena pelo nome da obra
-- Q18 JOIN pela entidade associativa
SELECT o.nome_obra, a.nome_autor -- obra e seu autor
FROM obra o -- parte da tabela obra
JOIN autoria au ON au.id_obra = o.id_obra -- passa pela autoria da obra
JOIN autor a ON a.id_autoria = au.id_autoria -- chega aos autores da autoria
ORDER BY o.nome_obra; -- ordena pelo nome da obra
-- Q19 GROUP BY e COUNT
SELECT l.nome_livro, COUNT(ex.id_exemplar) AS qtd_exemplares -- livro e quantidade de copias
FROM livro l -- parte da tabela livro
JOIN exemplar ex ON ex.id_livro = l.id_livro -- junta os exemplares de cada livro
GROUP BY l.id_livro, l.nome_livro -- agrupa por livro
ORDER BY qtd_exemplares DESC; -- do que tem mais copias para o que tem menos
-- Q20 GROUP BY e HAVING
SELECT le.nome_leitor, COUNT(*) AS total_emprestimos -- leitor e total de emprestimos
FROM emprestimo e -- parte da tabela emprestimo
JOIN leitor le ON le.id_leitor = e.id_leitor -- junta com o leitor
GROUP BY le.id_leitor, le.nome_leitor -- agrupa por leitor
HAVING COUNT(*) > 1; -- so leitores com mais de um emprestimo
-- Q21 subconsulta com NOT IN
SELECT id_exemplar, id_livro FROM exemplar -- colunas exibidas da tabela exemplar
WHERE id_exemplar NOT IN (SELECT id_exemplar FROM emprestimo); -- exemplares nunca emprestados
-- Q22 subconsulta com funcao de agregacao
SELECT le.nome_leitor, m.valor -- leitor e valor da multa
FROM multa m -- parte da tabela multa
JOIN devolucao d ON d.id_devolucao = m.id_devolucao -- liga a multa a devolucao
JOIN emprestimo e ON e.id_emprestimo = d.id_emprestimo -- liga a devolucao ao emprestimo
JOIN leitor le ON le.id_leitor = e.id_leitor -- liga o emprestimo ao leitor
WHERE m.valor > (SELECT AVG(valor) FROM multa); -- multas acima da media
-- Q23 LEFT JOIN: emprestimos em aberto e dias de atraso
SELECT le.nome_leitor, li.nome_livro, e.data_devolucao AS prazo, -- leitor, livro e prazo
 GREATEST(DATEDIFF(CURRENT_DATE, e.data_devolucao), 0) AS dias_atraso -- dias de atraso ate hoje (minimo 0)
FROM emprestimo e -- parte da tabela emprestimo
JOIN leitor le ON le.id_leitor = e.id_leitor -- junta com o leitor
JOIN exemplar ex ON ex.id_exemplar = e.id_exemplar -- junta com o exemplar
JOIN livro li ON li.id_livro = ex.id_livro -- junta com o livro
LEFT JOIN devolucao d ON d.id_emprestimo = e.id_emprestimo -- junta a devolucao, se houver
WHERE d.id_devolucao IS NULL -- so emprestimos sem devolucao (em aberto)
ORDER BY dias_atraso DESC; -- maiores atrasos primeiro
-- Q24 UNION
SELECT nome_leitor AS nome, 'Leitor' AS tipo FROM leitor -- nomes dos leitores com o tipo Leitor
UNION -- une os dois resultados, sem repetidos
SELECT nome_funcionario, 'Funcionario' FROM funcionario -- nomes dos funcionarios com o tipo Funcionario
ORDER BY nome; -- ordena a lista final pelo nome

-- 4.3 Testes das consultas avancadas
-- P1 + T1 + T2
CALL sp_registrar_emprestimo(4, 1, 14); -- Ana (leitor 1) pega o exemplar 4 por 14 dias
SELECT id_exemplar, situacao_exemplar FROM exemplar WHERE id_exemplar = 4; -- confere que o exemplar 4 virou Emprestado
-- T1 bloqueando: Diego (leitor 4) tem multa em aberto
CALL sp_registrar_emprestimo(7, 4, 14); -- deve dar erro: Leitor possui multa em aberto
-- P2 + T3: Ana devolve Dom Casmurro (emprestimo 8, prazo 08/11/2026) com atraso
CALL sp_registrar_devolucao(8, 3); -- registra a devolucao e gera a multa automaticamente
-- P3
CALL sp_pagar_multa(4); -- paga a multa 4 (gerada pela devolucao acima)
