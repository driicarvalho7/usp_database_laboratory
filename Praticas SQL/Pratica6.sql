-- 1.
    -- a)

        -- SESSÃO 1
        SELECT * FROM L05_DISPUTA WHERE ID = 7;

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

        UPDATE L05_DISPUTA SET VENCEDOR = 'Alemanha' WHERE ID = 7;

        -- A alteração continua na Sessão 1 até que execute o COMMIT
        COMMIT;


        -- SESSÃO 2
        SELECT * FROM L05_DISPUTA WHERE ID = 7;

        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

        UPDATE L05_DISPUTA SET VENCEDOR = 'Brasil' WHERE ID = 7;

        -- A alteração continua na Sessão 2 até que execute o COMMIT
        COMMIT;

        -- iv. A Sessão 2 exibe o resultado do vencedor 'Brasil' que é o Antigo a Update realizado na Sessão 1.
        -- vi. O Update da Sessão 2 fica em um estado 'infinito' de loading, aguardando que a transação da Sessão 1 
        --     seja commitada, assim que é realizado o commit, o Update da Sessão 2 é realizado.
        -- x. A Sessão 2 exibe o resultado do vencedor 'Alemanha' conforme o Update da Sessão 1.
        -- xii. A Sessão 2 concluíu o o Update, sem ficar em um estado 'infinito'.

    -- b)

        -- SESSÃO 1
        SELECT * FROM L05_DISPUTA WHERE ID = 7;

        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        UPDATE L05_DISPUTA SET VENCEDOR = 'Alemanha' WHERE ID = 7;

        -- A alteração continua na Sessão 1 até que execute o COMMIT
        COMMIT;


        -- SESSÃO 2
        SELECT * FROM L05_DISPUTA WHERE ID = 7;

        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        UPDATE L05_DISPUTA SET VENCEDOR = 'Brasil' WHERE ID = 7;

        -- A alteração continua na Sessão 2 até que execute o COMMIT
        COMMIT;

        -- Os resultado em relação ao item a) são iguais em relação as consultas, a principal diferença é que com 
        -- 'SERIALIZABLE' o Update que está ocorrendo na Sessão 2 não é concluído e é exibida a mensagem de erro:

        -- Erro a partir da linha : 5 no comando -
        -- UPDATE L05_DISPUTA SET VENCEDOR = 'Brasil' WHERE ID = 7
        -- Relatório de erros -
        -- ORA-08177: não é possível serializar o acesso para esta transação


-- 2.
    -- a)

        CREATE OR REPLACE VIEW V_Ranking_Medalhas_Olimpiadas AS
        WITH Vitorias AS (
            -- Contagem de vitórias por país, olimpíada e modalidade
            SELECT VENCEDOR AS Pais,
                OLIMPIADA,
                MODALIDADE,
                COUNT(*) AS Numero_Vitorias,
                RANK() OVER (PARTITION BY OLIMPIADA, MODALIDADE ORDER BY COUNT(*) DESC, MAX(DATA_HORA) DESC) AS Ranking
            FROM L05_DISPUTA
            GROUP BY VENCEDOR, OLIMPIADA, MODALIDADE
        ),
        Medalhistas AS (
            -- Seleciona os países que ganharam ouro, prata e bronze
            SELECT 
                OLIMPIADA,
                MODALIDADE,
                MAX(CASE WHEN Ranking = 1 THEN Pais END) AS Ouro,
                MAX(CASE WHEN Ranking = 2 THEN Pais END) AS Prata,
                MAX(CASE WHEN Ranking = 3 THEN Pais END) AS Bronze
            FROM Vitorias
            GROUP BY OLIMPIADA, MODALIDADE
        ),
        Medalhas_Totais AS (
            -- Agrega o total de ouros, pratas e bronzes por país
            SELECT 
                Ouro AS Pais, 
                COUNT(Ouro) AS Total_Ouros, 
                0 AS Total_Pratras, 
                0 AS Total_Bronzes
            FROM Medalhistas
            WHERE Ouro IS NOT NULL
            GROUP BY Ouro
            UNION ALL
            SELECT 
                Prata AS Pais, 
                0 AS Total_Ouros, 
                COUNT(Prata) AS Total_Pratras, 
                0 AS Total_Bronzes
            FROM Medalhistas
            WHERE Prata IS NOT NULL
            GROUP BY Prata
            UNION ALL
            SELECT 
                Bronze AS Pais, 
                0 AS Total_Ouros, 
                0 AS Total_Pratras, 
                COUNT(Bronze) AS Total_Bronzes
            FROM Medalhistas
            WHERE Bronze IS NOT NULL
            GROUP BY Bronze
        )
        SELECT 
            Pais,
            SUM(Total_Ouros) AS Total_Ouros,
            SUM(Total_Pratras) AS Total_Pratras,
            SUM(Total_Bronzes) AS Total_Bronzes,
            RANK() OVER (ORDER BY SUM(Total_Ouros) DESC, SUM(Total_Pratras) DESC, SUM(Total_Bronzes) DESC) AS Ranking_Geral
        FROM Medalhas_Totais
        GROUP BY Pais;


        SELECT * FROM V_Ranking_Medalhas_Olimpiadas;

    -- b)

        CREATE OR REPLACE VIEW V_Ranking_Medalhas_Rio2016 AS
        WITH Vitorias AS (
            -- Contagem de vitórias por país, para a olimpíada de 2016 e modalidade
            SELECT VENCEDOR AS Pais,
                OLIMPIADA,
                MODALIDADE,
                COUNT(*) AS Numero_Vitorias,
                RANK() OVER (PARTITION BY MODALIDADE ORDER BY COUNT(*) DESC, MAX(DATA_HORA) DESC) AS Ranking
            FROM L05_DISPUTA
            WHERE OLIMPIADA = 2016
            GROUP BY VENCEDOR, OLIMPIADA, MODALIDADE
        ),
        Medalhistas AS (
            -- Seleciona os países que ganharam ouro, prata e bronze para a olimpíada de 2016
            SELECT 
                MODALIDADE,
                MAX(CASE WHEN Ranking = 1 THEN Pais END) AS Ouro,
                MAX(CASE WHEN Ranking = 2 THEN Pais END) AS Prata,
                MAX(CASE WHEN Ranking = 3 THEN Pais END) AS Bronze
            FROM Vitorias
            GROUP BY MODALIDADE
        ),
        Medalhas_Totais AS (
            -- Agrega o total de ouros, pratas e bronzes por país
            SELECT 
                Ouro AS Pais, 
                COUNT(Ouro) AS Total_Ouros, 
                0 AS Total_Pratras, 
                0 AS Total_Bronzes
            FROM Medalhistas
            WHERE Ouro IS NOT NULL
            GROUP BY Ouro
            UNION ALL
            SELECT 
                Prata AS Pais, 
                0 AS Total_Ouros, 
                COUNT(Prata) AS Total_Pratras, 
                0 AS Total_Bronzes
            FROM Medalhistas
            WHERE Prata IS NOT NULL
            GROUP BY Prata
            UNION ALL
            SELECT 
                Bronze AS Pais, 
                0 AS Total_Ouros, 
                0 AS Total_Pratras, 
                COUNT(Bronze) AS Total_Bronzes
            FROM Medalhistas
            WHERE Bronze IS NOT NULL
            GROUP BY Bronze
        )
        SELECT 
            Pais,
            SUM(Total_Ouros) AS Total_Ouros,
            SUM(Total_Pratras) AS Total_Pratras,
            SUM(Total_Bronzes) AS Total_Bronzes,
            RANK() OVER (ORDER BY SUM(Total_Ouros) DESC, SUM(Total_Pratras) DESC, SUM(Total_Bronzes) DESC) AS Ranking_Geral
        FROM Medalhas_Totais
        GROUP BY Pais;

        SELECT * FROM V_Ranking_Medalhas_Rio2016;

    -- c)

        CREATE OR REPLACE VIEW V_Contratos_Patrocinio AS
        SELECT
            p.NOME AS Nome_Patrocinador,
            a.NOME AS Nome_Atleta,
            a.PAIS AS Pais_Atleta,
            pa.INICIO AS Inicio_Contrato,
            ADD_MONTHS(pa.INICIO, pa.VIGENCIA) AS Termino_Contrato, -- Calcula a data final do contrato em meses
            pa.VIGENCIA AS Tempo_Vigencia
        FROM
            L09_PATROCINA pa
        JOIN
            L08_PATROCINADOR p ON pa.PATROCINADOR = p.ID
        JOIN
            L06_ATLETA a ON pa.ATLETA = a.PASSAPORTE;
            
        SELECT * FROM V_Contratos_Patrocinio;

    -- d)

        CREATE OR REPLACE VIEW V_Disputas_Atleta AS
        SELECT
            a.NOME AS Nome_Atleta,
            m.ESPORTE AS Esporte,
            a.GENERO AS Genero,
            COUNT(j.DISPUTA) AS Total_Disputas
        FROM
            L06_ATLETA a
        JOIN
            L07_JOGA j ON a.PASSAPORTE = j.ATLETA
        JOIN
            L03_MODALIDADE m ON a.MODALIDADE = m.ID
        GROUP BY
            a.NOME, m.ESPORTE, a.GENERO
        ORDER BY Total_Disputas DESC;

        SELECT * FROM V_Disputas_Atleta;

    -- e)

        CREATE OR REPLACE VIEW V_Ranking_Atletas AS
        WITH Atletas_Disputas AS (
            SELECT
                a.NOME AS Nome_Atleta,
                m.ESPORTE AS Esporte,
                a.GENERO AS Genero,
                COUNT(j.DISPUTA) AS Total_Disputas
            FROM
                L06_ATLETA a
            JOIN
                L07_JOGA j ON a.PASSAPORTE = j.ATLETA
            JOIN
                L03_MODALIDADE m ON a.MODALIDADE = m.ID
            GROUP BY
                a.NOME, m.ESPORTE, a.GENERO
        )
        SELECT
            Nome_Atleta,
            Esporte,
            Genero,
            Total_Disputas,
            RANK() OVER (ORDER BY Total_Disputas DESC) AS Ranking
        FROM
            Atletas_Disputas;
            
        SELECT * FROM V_Ranking_Atletas;

-- 3.

    -- a) 
    
        -- O programa Python apresentará um erro ao tentar executar a consulta SQL, 
        -- pois a coluna PASSAPORTE não existe mais.

    -- b) 
    
        -- Criar uma VIEW da tabela Atletas, para que caso alguma coluna seja alterada,
        -- também deverá ser alterada a VIEW passando o nome da antiga coluna.

        -- Criando a View no banco de dados caso 'PASSAPORTE' seja trocado para 'DOC_IDENTIDADE'
        CREATE OR REPLACE VIEW V_ATLETA AS
        SELECT 
            DOC_IDENTIDADE AS PASSAPORTE,  -- Mapeia o novo nome da coluna para o nome antigo
            NOME, 
            PAIS
        FROM 
            L06_ATLETA;

        -- Alteração do código Python para funcionar em caso de renomear colunas futuras:
        import cx_Oracle

        con = cx_Oracle.connect("username/password@localhost/ORCL1")
        cur = con.cursor()

        cur.execute("SELECT * FROM V_ATLETA")
        for row in cur:
            passaporte, nome, pais = row
            print(f"Passaporte: {passaporte}, Nome: {nome}, País: {pais}")

        cur.close()
        con.close()


-- 4.

    -- a)

        -- Usuário L13692400 (Adriano Carvalho)
        GRANT SELECT ON L01_PAIS TO Teste16 WITH GRANT OPTION;
        GRANT SELECT ON L02_OLIMPIADA TO Teste16 WITH GRANT OPTION;

        -- Usuário Teste16
        CREATE OR REPLACE VIEW V_USER1 AS
        SELECT 
            p.CONTINENTE, 
            p.NOME,
            o.ANO, 
            o.CIDADE_SEDE,
            o.DATA_INICIO, 
            o.DATA_ENCERRAMENTO
        FROM L13692400.L01_PAIS p
        RIGHT JOIN L13692400.L02_OLIMPIADA o
        ON p.NOME = o.PAIS
        ORDER BY o.ANO DESC;

        GRANT SELECT ON V_USER1 TO Teste17;

        -- Usuário Teste17
        SELECT * FROM Teste16.V_USER1;

    -- b)

        -- Usuário L13692400 (Adriano Carvalho)
        CREATE TABLE L12_MAT_ESPORTIVO (
            ID INTEGER PRIMARY KEY,
            DESCRICAO VARCHAR2(100),
            PRECO NUMBER(10, 2),
            ATLETA VARCHAR2(10) REFERENCES L06_ATLETA(PASSAPORTE) 
        );

        GRANT REFERENCES ON L13692400.L12_MAT_ESPORTIVO TO Teste16;

        INSERT INTO L12_MAT_ESPORTIVO (ID, DESCRICAO, PRECO, ATLETA)
        VALUES (1, 'Tênis Nike', 299.00, 'BR12345');

        INSERT INTO L12_MAT_ESPORTIVO (ID, DESCRICAO, PRECO, ATLETA)
        VALUES (2, 'Canhoteira Nike', 59.00, 'BR98765');

        INSERT INTO Teste16.L13_ESTOQUE (ID, QTD_ESTOQUE)
        VALUES (1, 15);

        INSERT INTO Teste16.L13_ESTOQUE (ID, QTD_ESTOQUE)
        VALUES (2, 30);

        -- Usuário Teste16
        CREATE TABLE L13_ESTOQUE (
            ID INTEGER PRIMARY KEY,
            QTD_ESTOQUE INTEGER NOT NULL,
            CONSTRAINT FK_ESTOQUE_MAT FOREIGN KEY (ID) REFERENCES L13692400.L12_MAT_ESPORTIVO(ID)
        );

        GRANT INSERT ON L13_ESTOQUE TO L13692400;

    -- c)

        -- Usuário L13692400 (Adriano Carvalho)
        CREATE TABLE L14_VENDAS (
            ID INTEGER PRIMARY KEY,
            ITEM INTEGER,
            QTD INTEGER NOT NULL,
            VALOR_TOTAL NUMBER(10, 2),
            CONSTRAINT FK_ITEM_VENDA FOREIGN KEY (ITEM) REFERENCES L12_MAT_ESPORTIVO(ID)
        );

        CREATE OR REPLACE TRIGGER trg_atualiza_estoque_calcula_valor_total
        BEFORE INSERT ON L14_VENDAS
        FOR EACH ROW
        DECLARE
            v_preco_unitario NUMBER(10, 2); 
            v_estoque_atual INTEGER;
        BEGIN
            -- Buscar o estoque atual do item na tabela L13_ESTOQUE
            SELECT QTD_ESTOQUE INTO v_estoque_atual
            FROM Teste16.L13_ESTOQUE
            WHERE ID = :NEW.ITEM;
            
            -- Verificar se a quantidade a ser vendida é maior que a quantidade em estoque
            IF :NEW.QTD > v_estoque_atual THEN
                -- Lança um erro caso a quantidade vendida seja maior que o estoque disponível
                RAISE_APPLICATION_ERROR(-20001, 'Estoque insuficiente para este item.');
            ELSE
                -- Atualiza o estoque do item na tabela L13_ESTOQUE
                UPDATE Teste16.L13_ESTOQUE
                SET QTD_ESTOQUE = QTD_ESTOQUE - :NEW.QTD
                WHERE ID = :NEW.ITEM;
            END IF;
            
            -- Buscar o preço do item na tabela L12_MAT_ESPORTIVO
            SELECT PRECO INTO v_preco_unitario
            FROM L12_MAT_ESPORTIVO
            WHERE ID = :NEW.ITEM;

            -- Calcular o valor total da venda
            :NEW.VALOR_TOTAL := v_preco_unitario * :NEW.QTD;
        END;

        -- Verificar estoque ANTES de inserir
        SELECT * FROM Teste16.L13_ESTOQUE;

        INSERT INTO L14_VENDAS (ID, ITEM, QTD)
        VALUES (5, 1, 491);

        INSERT INTO L14_VENDAS (ID, ITEM, QTD)
        VALUES (4, 2, 10);

        -- Verificar estoque APÓS de inserir
        SELECT * FROM Teste16.L13_ESTOQUE;

        SELECT * FROM L14_VENDAS;
