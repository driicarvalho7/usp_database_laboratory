-- 1.

    CREATE OR REPLACE PACKAGE olimpiadas IS
        TYPE medalhistas_t IS RECORD (
            ouro   VARCHAR2(150),
            prata  VARCHAR2(150),
            bronze VARCHAR2(150)
        );

        FUNCTION podio(p_olimpiada L05_DISPUTA.OLIMPIADA%TYPE, 
                    p_modalidade L05_DISPUTA.MODALIDADE%TYPE) 
        RETURN medalhistas_t;
    END olimpiadas;
    /

    CREATE OR REPLACE PACKAGE BODY olimpiadas IS
        FUNCTION podio(p_olimpiada L05_DISPUTA.OLIMPIADA%TYPE, 
                    p_modalidade L05_DISPUTA.MODALIDADE%TYPE) 
        RETURN medalhistas_t IS
            medalhistas medalhistas_t;
            
        BEGIN
            WITH Vitorias AS (
                -- Conta o número de vitórias e rankea os países
                SELECT VENCEDOR AS Pais,
                    COUNT(*) AS Numero_Vitorias,
                    RANK() OVER (ORDER BY COUNT(*) DESC) AS Ranking
                FROM L05_DISPUTA
                WHERE OLIMPIADA = p_olimpiada
                AND MODALIDADE = p_modalidade
                GROUP BY VENCEDOR
            ),
            Medalhista_Ouro AS (
                -- Seleciona o país com o maior número de vitórias e, em caso de empate, o mais recente
                SELECT Pais
                FROM Vitorias
                JOIN L05_DISPUTA D ON Vitorias.Pais = D.VENCEDOR
                WHERE Ranking = 1
                AND D.OLIMPIADA = p_olimpiada
                AND D.MODALIDADE = p_modalidade
                ORDER BY D.DATA_HORA DESC
                FETCH FIRST ROW ONLY
            ),
            Medalhista_Prata AS (
                -- Seleciona o medalhista de prata
                SELECT Pais
                FROM Vitorias
                WHERE Ranking = 2
                FETCH FIRST ROW ONLY
            ),
            Medalhista_Bronze_Candidates AS (
                -- Seleciona todos os países com o terceiro maior número de vitórias
                SELECT Pais
                FROM Vitorias
                WHERE Ranking = 3
            ),
            Medalhista_Bronze AS (
                -- Seleciona o país mais recente a perder para o medalhista de ouro
                SELECT MB.Pais
                FROM Medalhista_Bronze_Candidates MB
                JOIN L05_DISPUTA D ON MB.Pais IN (D.PAIS1, D.PAIS2)
                WHERE D.VENCEDOR = (SELECT Pais FROM Medalhista_Ouro)
                AND D.OLIMPIADA = p_olimpiada
                AND D.MODALIDADE = p_modalidade
                ORDER BY D.DATA_HORA DESC
                FETCH FIRST ROW ONLY
            )
            SELECT 
                (SELECT Pais FROM Medalhista_Ouro) AS Ouro,
                (SELECT Pais FROM Medalhista_Prata) AS Prata,
                (SELECT Pais FROM Medalhista_Bronze) AS Bronze
            INTO medalhistas.ouro, medalhistas.prata, medalhistas.bronze
            FROM DUAL;

            RETURN medalhistas;
        END podio;
    END olimpiadas;
    /

    DECLARE
        medalhistas olimpiadas.medalhistas_t;
    BEGIN
        medalhistas := olimpiadas.podio(2008, 1);
        DBMS_OUTPUT.PUT_LINE('Ouro: ' || medalhistas.ouro);
        DBMS_OUTPUT.PUT_LINE('Prata: ' || medalhistas.prata);
        DBMS_OUTPUT.PUT_LINE('Bronze: ' || medalhistas.bronze);
    END;
    /

-- 3.

    ALTER TABLE L01_PAIS
    ADD (TOTAL_OUROS NUMBER DEFAULT 0,
        TOTAL_PRATAS NUMBER DEFAULT 0,
        TOTAL_BRONZES NUMBER DEFAULT 0);

    CREATE OR REPLACE PROCEDURE atualizar_medalhas_pais IS
        medalhistas olimpiadas.medalhistas_t;
    BEGIN
        -- Resetando os contadores de medalhas
        UPDATE L01_PAIS
        SET TOTAL_OUROS = 0, TOTAL_PRATAS = 0, TOTAL_BRONZES = 0;

        -- Loop por cada olimpíada e modalidade
        FOR olimpiada_rec IN (SELECT DISTINCT OLIMPIADA FROM L05_DISPUTA) LOOP
            FOR modalidade_rec IN (SELECT DISTINCT MODALIDADE FROM L05_DISPUTA WHERE OLIMPIADA = olimpiada_rec.OLIMPIADA) LOOP
                -- Obtendo os medalhistas
                medalhistas := olimpiadas.podio(olimpiada_rec.OLIMPIADA, modalidade_rec.MODALIDADE);

                -- Atualizando o total de ouros
                IF medalhistas.ouro IS NOT NULL THEN
                    UPDATE L01_PAIS
                    SET TOTAL_OUROS = TOTAL_OUROS + 1
                    WHERE NOME = medalhistas.ouro;
                END IF;

                -- Atualizando o total de pratas
                IF medalhistas.prata IS NOT NULL THEN
                    UPDATE L01_PAIS
                    SET TOTAL_PRATAS = TOTAL_PRATAS + 1
                    WHERE NOME = medalhistas.prata;
                END IF;

                -- Atualizando o total de bronzes
                IF medalhistas.bronze IS NOT NULL THEN
                    UPDATE L01_PAIS
                    SET TOTAL_BRONZES = TOTAL_BRONZES + 1
                    WHERE NOME = medalhistas.bronze;
                END IF;
            END LOOP;
        END LOOP;

        COMMIT;
    END atualizar_medalhas_pais;

    BEGIN
        atualizar_medalhas_pais;
    END;
    /
