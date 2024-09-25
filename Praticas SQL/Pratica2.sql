-- 2.

    -- a)

        CREATE SEQUENCE SEQ_EVENTO
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE
        NOCYCLE
        NOCACHE;

        CREATE SEQUENCE SEQ_EMISSORA
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE
        NOCYCLE
        NOCACHE;

        CREATE SEQUENCE SEQ_PODIO
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE
        NOCYCLE
        NOCACHE;

        CREATE SEQUENCE SEQ_PAIS
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE
        NOCYCLE
        NOCACHE;

        CREATE SEQUENCE SEQ_MODALIDADE
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE
        NOCYCLE
        NOCACHE;

        CREATE SEQUENCE SEQ_ATLETA
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE
        NOCYCLE
        NOCACHE;

        CREATE SEQUENCE SEQ_PATROCINADOR
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE
        NOCYCLE
        NOCACHE;

        CREATE SEQUENCE SEQ_CONTRATO
        START WITH 1
        INCREMENT BY 1
        NOMAXVALUE
        NOCYCLE
        NOCACHE;

    -- b)

        CREATE TABLE PAIS (
            ID INTEGER,
            NOME VARCHAR2(30) NOT NULL,
            CONTINENTE VARCHAR2(30),
            POPULACAO NUMBER(15),

            CONSTRAINT PK_PAIS PRIMARY KEY (ID),
            CONSTRAINT UK_PAIS UNIQUE (NOME)
        );

        CREATE TABLE OLIMPIADA (
            ANO NUMBER(4),
            SEDE VARCHAR2(30) NOT NULL,
            CAMPEAO INTEGER,

            CONSTRAINT PK_OLIMPIADA PRIMARY KEY (ANO),
            CONSTRAINT FK_OLIMPIADA FOREIGN KEY (CAMPEAO)
                REFERENCES PAIS(ID)
                ON DELETE CASCADE
        );

        CREATE TABLE MODALIDADE (
            ID INTEGER,
            NOME VARCHAR2(30) NOT NULL,
            GENERO CHAR(1) NOT NULL,
            EQUIPE CHAR(1),

            CONSTRAINT PK_MODALIDADE PRIMARY KEY (ID),
            CONSTRAINT CK_MODALIDADE CHECK (EQUIPE IN ('Y', 'N'))
        );

        CREATE TABLE EVENTO (
            ID INTEGER,
            DATA_HORA TIMESTAMP WITH TIME ZONE,
            LOCAL VARCHAR2(30),
            TEMPO_DURACAO INTERVAL DAY TO SECOND,
            MODALIDADE INTEGER,
            OLIMPIADA NUMBER(4),
            PAIS1 INTEGER,
            PAIS2 INTEGER,
            VENCEDOR INTEGER,

            CONSTRAINT PK_EVENTO PRIMARY KEY (ID),
            CONSTRAINT FK_EVENTO_MODALIDADE FOREIGN KEY (MODALIDADE)
                REFERENCES MODALIDADE(ID)
                ON DELETE CASCADE,
            CONSTRAINT FK_EVENTO_OLIMPIADA FOREIGN KEY (OLIMPIADA)
                REFERENCES OLIMPIADA(ANO)
                ON DELETE CASCADE,
            CONSTRAINT FK_EVENTO_PAIS1 FOREIGN KEY (PAIS1)
                REFERENCES PAIS(ID)
                ON DELETE CASCADE,
            CONSTRAINT FK_EVENTO_PAIS2 FOREIGN KEY (PAIS2)
                REFERENCES PAIS(ID)
                ON DELETE CASCADE,
            CONSTRAINT CK_EVENTO CHECK (PAIS1 != PAIS2)
        );

        CREATE TABLE EMISSORA (
            ID INTEGER,
            NOME VARCHAR2(30) NOT NULL,
            PAIS INTEGER,

            CONSTRAINT PK_EMISSORA PRIMARY KEY (ID),
            CONSTRAINT FK_EMISSORA FOREIGN KEY (PAIS)
                REFERENCES PAIS(ID)
                ON DELETE CASCADE
        );

        CREATE TABLE EMISSORA_TIPO (
            EMISSORA INTEGER,
            TIPO VARCHAR2(9),

            CONSTRAINT PK_EMISSORA_TIPO PRIMARY KEY (EMISSORA, TIPO),
            CONSTRAINT FK_EMISSORA_TIPO FOREIGN KEY (EMISSORA)
                REFERENCES EMISSORA(ID)
                ON DELETE CASCADE,
            CONSTRAINT CK_EMISSORA_TIPO CHECK (TIPO IN ('Radio', 'TV', 'Streaming'))
        );

        CREATE TABLE TRANSMISSAO (
            EMISSORA INTEGER,
            EQUIPE INTEGER,
            CANAL INTEGER NOT NULL,

            CONSTRAINT PK_TRANSMISSAO PRIMARY KEY (EMISSORA, EQUIPE),
            CONSTRAINT FK_TRANSMISSAO_EMISSORA FOREIGN KEY (EMISSORA)
                REFERENCES EMISSORA(ID)
                ON DELETE CASCADE,
            CONSTRAINT FK_TRANSMISSAO_EQUIPE FOREIGN KEY (EQUIPE)
                REFERENCES EVENTO(ID)
                ON DELETE CASCADE
        );

        CREATE TABLE PODIO (
            ID INTEGER,
            OURO INTEGER,
            PRATA INTEGER,
            BRONZE INTEGER,
            MODALIDADE INTEGER,
            OLIMPIADA NUMBER(4),

            CONSTRAINT PK_PODIO PRIMARY KEY (ID),
            CONSTRAINT FK_PODIO_OURO FOREIGN KEY (OURO)
                REFERENCES PAIS(ID)
                ON DELETE CASCADE,
            CONSTRAINT FK_PODIO_PRATA FOREIGN KEY (PRATA)
                REFERENCES PAIS(ID)
                ON DELETE CASCADE,
            CONSTRAINT FK_PODIO_BRONZE FOREIGN KEY (BRONZE)
                REFERENCES PAIS(ID)
                ON DELETE CASCADE,
            CONSTRAINT FK_PODIO_MODALIDADE FOREIGN KEY (MODALIDADE)
                REFERENCES MODALIDADE(ID)
                ON DELETE CASCADE,
            CONSTRAINT FK_PODIO_OLIMPIADA FOREIGN KEY (OLIMPIADA)
                REFERENCES OLIMPIADA(ANO)
                ON DELETE CASCADE,
            CONSTRAINT CK_PODIO CHECK (OURO != PRATA AND PRATA != BRONZE AND OURO != BRONZE)
        );

        CREATE TABLE ATLETA (
            ID INTEGER,
            NOME VARCHAR2(30) NOT NULL,
            IDADE NUMBER(3) NOT NULL,
            GENERO CHAR(1) NOT NULL,
            PAIS INTEGER,
            MODALIDADE INTEGER,
            
            CONSTRAINT PK_ATLETA PRIMARY KEY (ID),
            CONSTRAINT FK_ATLETA_PAIS FOREIGN KEY (PAIS)
                REFERENCES PAIS(ID)
                ON DELETE CASCADE,
            CONSTRAINT FK_ATLETA_MODALIDADE FOREIGN KEY (MODALIDADE)
                REFERENCES MODALIDADE(ID)
                ON DELETE CASCADE
        );

        CREATE TABLE PATROCINADOR (
            ID INTEGER,
            NOME VARCHAR2(30) NOT NULL,
            RAMO_ATUACAO VARCHAR2(30),
            CODIGO_POSTAL VARCHAR2(10),
            RUA VARCHAR2(30),
            NUMERO INTEGER,
            BAIRRO VARCHAR2(30),
            CIDADE VARCHAR2(30),
            ESTADO VARCHAR2(30),
            PAIS INTEGER,

            CONSTRAINT PK_PATROCINADOR PRIMARY KEY (ID),
            CONSTRAINT FK_PATROCINADOR FOREIGN KEY (PAIS)
                REFERENCES PAIS(ID)
                ON DELETE CASCADE
        );

        CREATE TABLE CONTRATO (
            ID INTEGER,
            DATA_INICIO DATE NOT NULL,
            VIGENCIA_MESES INTEGER NOT NULL,
            VALOR_CONTRATO INTEGER NOT NULL,
            ATLETA INTEGER,
            PATROCINADOR INTEGER,

            CONSTRAINT PK_CONTRATO PRIMARY KEY (ID),
            CONSTRAINT FK_CONTRATO_ATLETA FOREIGN KEY (ATLETA)
                REFERENCES ATLETA(ID)
                ON DELETE CASCADE,
            CONSTRAINT FK_CONTRATO_PATROCINADOR FOREIGN KEY (PATROCINADOR)
                REFERENCES PATROCINADOR(ID)
                ON DELETE CASCADE
        );

-- 3.

    -- a)

        INSERT INTO PAIS (ID, NOME, CONTINENTE, POPULACAO)
        VALUES (SEQ_PAIS.NEXTVAL, 'Brasil', 'América do Sul', 211000000);

        INSERT INTO PAIS (ID, NOME, CONTINENTE, POPULACAO)
        VALUES (SEQ_PAIS.NEXTVAL, 'Japão', 'Ásia', 126000000);

        INSERT INTO PAIS (ID, NOME, CONTINENTE, POPULACAO)
        VALUES (SEQ_PAIS.NEXTVAL, 'Estados Unidos', 'América do Norte', 333000000);


        INSERT INTO OLIMPIADA (ANO, SEDE, CAMPEAO)
        VALUES (2024, 'Paris', NULL);

        INSERT INTO OLIMPIADA (ANO, SEDE, CAMPEAO)
        VALUES (2016, 'Rio de Janeiro', (SELECT ID FROM PAIS WHERE NOME = 'Brasil'));


        INSERT INTO MODALIDADE (ID, NOME, GENERO, EQUIPE)
        VALUES (SEQ_MODALIDADE.NEXTVAL, 'Futebol', 'M', 'Y');

        INSERT INTO MODALIDADE (ID, NOME, GENERO, EQUIPE)
        VALUES (SEQ_MODALIDADE.NEXTVAL, 'Ginástica', 'F', 'N');


        INSERT INTO EVENTO (ID, DATA_HORA, LOCAL, TEMPO_DURACAO, MODALIDADE, OLIMPIADA, PAIS1, PAIS2, VENCEDOR)
        VALUES (SEQ_EVENTO.NEXTVAL, 
                TO_TIMESTAMP_TZ('2024-07-26 20:00:00 +02:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 
                'Parc des Princes', 
                INTERVAL '02:30:00' HOUR TO SECOND, 
                (SELECT ID FROM MODALIDADE WHERE NOME = 'Futebol'), 
                2024, 
                (SELECT ID FROM PAIS WHERE NOME = 'Brasil'), 
                (SELECT ID FROM PAIS WHERE NOME = 'Japão'), 
                (SELECT ID FROM PAIS WHERE NOME = 'Brasil'));

        INSERT INTO EVENTO (ID, DATA_HORA, LOCAL, TEMPO_DURACAO, MODALIDADE, OLIMPIADA, PAIS1, PAIS2, VENCEDOR)
        VALUES (SEQ_EVENTO.NEXTVAL, 
                TO_TIMESTAMP_TZ('2016-08-12 15:00:00 -03:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM'), 
                'Arena Bercy', 
                INTERVAL '01:45:00' HOUR TO SECOND, 
                (SELECT ID FROM MODALIDADE WHERE NOME = 'Ginástica'), 
                2016, 
                (SELECT ID FROM PAIS WHERE NOME = 'Brasil'), 
                (SELECT ID FROM PAIS WHERE NOME = 'Japão'), 
                (SELECT ID FROM PAIS WHERE NOME = 'Japão'));


        INSERT INTO EMISSORA (ID, NOME, PAIS)
        VALUES (SEQ_EMISSORA.NEXTVAL, 'Rede Globo', (SELECT ID FROM PAIS WHERE NOME = 'Brasil'));

        INSERT INTO EMISSORA (ID, NOME, PAIS)
        VALUES (SEQ_EMISSORA.NEXTVAL, 'NHK', (SELECT ID FROM PAIS WHERE NOME = 'Japão'));


        INSERT INTO EMISSORA_TIPO (EMISSORA, TIPO)
        VALUES ((SELECT ID FROM EMISSORA WHERE NOME = 'Rede Globo'), 'TV');

        INSERT INTO EMISSORA_TIPO (EMISSORA, TIPO)
        VALUES ((SELECT ID FROM EMISSORA WHERE NOME = 'NHK'), 'Streaming');


        INSERT INTO TRANSMISSAO (EMISSORA, EQUIPE, CANAL)
        VALUES ((SELECT ID FROM EMISSORA WHERE NOME = 'Rede Globo'), 
                (SELECT ID FROM EVENTO WHERE LOCAL = 'Parc des Princes'), 
                5);

        INSERT INTO TRANSMISSAO (EMISSORA, EQUIPE, CANAL)
        VALUES ((SELECT ID FROM EMISSORA WHERE NOME = 'NHK'), 
                (SELECT ID FROM EVENTO WHERE LOCAL = 'Arena Bercy'), 
                7);


        INSERT INTO PODIO (ID, OURO, PRATA, BRONZE, MODALIDADE, OLIMPIADA)
        VALUES (SEQ_PODIO.NEXTVAL, 
                (SELECT ID FROM PAIS WHERE NOME = 'Brasil'), 
                (SELECT ID FROM PAIS WHERE NOME = 'Japão'), 
                (SELECT ID FROM PAIS WHERE NOME = 'Estados Unidos'), 
                (SELECT ID FROM MODALIDADE WHERE NOME = 'Futebol'), 
                2024);

        INSERT INTO PODIO (ID, OURO, PRATA, BRONZE, MODALIDADE, OLIMPIADA)
        VALUES (SEQ_PODIO.NEXTVAL, 
                (SELECT ID FROM PAIS WHERE NOME = 'Estados Unidos'), 
                (SELECT ID FROM PAIS WHERE NOME = 'Brasil'),
                (SELECT ID FROM PAIS WHERE NOME = 'Japão'),
                (SELECT ID FROM MODALIDADE WHERE NOME = 'Ginástica'), 
                2016);


        INSERT INTO ATLETA (ID, NOME, IDADE, GENERO, PAIS, MODALIDADE)
        VALUES (SEQ_ATLETA.NEXTVAL, 'Neymar', 32, 'M', 
                (SELECT ID FROM PAIS WHERE NOME = 'Brasil'), 
                (SELECT ID FROM MODALIDADE WHERE NOME = 'Futebol'));

        INSERT INTO ATLETA (ID, NOME, IDADE, GENERO, PAIS, MODALIDADE)
        VALUES (SEQ_ATLETA.NEXTVAL, 'Simone Biles', 27, 'F', 
                (SELECT ID FROM PAIS WHERE NOME = 'Estados Unidos'), 
                (SELECT ID FROM MODALIDADE WHERE NOME = 'Ginástica'));


        INSERT INTO PATROCINADOR (ID, NOME, RAMO_ATUACAO, CODIGO_POSTAL, RUA, NUMERO, BAIRRO, CIDADE, ESTADO, PAIS)
        VALUES (SEQ_PATROCINADOR.NEXTVAL, 'Nike', 'Esportes', '10001', '6th Ave', 855, 'Downtown', 'Nova Iorque', 'NY', 
                (SELECT ID FROM PAIS WHERE NOME = 'Estados Unidos'));

        INSERT INTO PATROCINADOR (ID, NOME, RAMO_ATUACAO, CODIGO_POSTAL, RUA, NUMERO, BAIRRO, CIDADE, ESTADO, PAIS)
        VALUES (SEQ_PATROCINADOR.NEXTVAL, 'Toyota', 'Automotivo', '471-0826', 'Natl Rte', 1, 'Toyotacho', 'Toyota', 'Aichi', 
                (SELECT ID FROM PAIS WHERE NOME = 'Japão'));


        INSERT INTO CONTRATO (ID, DATA_INICIO, VIGENCIA_MESES, VALOR_CONTRATO, ATLETA, PATROCINADOR)
        VALUES (SEQ_CONTRATO.NEXTVAL, TO_DATE('2024-01-01', 'YYYY-MM-DD'), 24, 500000, 
                (SELECT ID FROM ATLETA WHERE NOME = 'Neymar'), 
                (SELECT ID FROM PATROCINADOR WHERE NOME = 'Toyota'));

        INSERT INTO CONTRATO (ID, DATA_INICIO, VIGENCIA_MESES, VALOR_CONTRATO, ATLETA, PATROCINADOR)
        VALUES (SEQ_CONTRATO.NEXTVAL, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 36, 750000, 
                (SELECT ID FROM ATLETA WHERE NOME = 'Simone Biles'), 
                (SELECT ID FROM PATROCINADOR WHERE NOME = 'Nike'));

    -- b)

        -- Atualizar a idade e o país de Neymar e Simone Biles
        UPDATE ATLETA
        SET IDADE = 33, PAIS = (SELECT ID FROM PAIS WHERE NOME = 'Japão')
        WHERE NOME = 'Neymar';

        UPDATE ATLETA
        SET IDADE = 28, PAIS = (SELECT ID FROM PAIS WHERE NOME = 'Brasil')
        WHERE NOME = 'Simone Biles';


        -- Remover eventos que ocorreram na Arena Bercy
        DELETE FROM EVENTO
        WHERE LOCAL = 'Arena Bercy';


-- 4.

    -- a)

        ALTER TABLE ATLETA
        ADD ALTURA NUMBER(3, 2) DEFAULT 1.75 CHECK (ALTURA > 0);

        SELECT * FROM ATLETA;

        INSERT INTO ATLETA (ID, NOME, IDADE, GENERO, PAIS, MODALIDADE)
        VALUES (SEQ_ATLETA.NEXTVAL, 'Usain Bolt', 34, 'M', 
                (SELECT ID FROM PAIS WHERE NOME = 'Jamaica'), 
                (SELECT ID FROM MODALIDADE WHERE NOME = 'Atletismo'));

        SELECT * FROM ATLETA WHERE NOME = 'Usain Bolt';

        INSERT INTO ATLETA (ID, NOME, IDADE, GENERO, PAIS, MODALIDADE, ALTURA)
        VALUES (SEQ_ATLETA.NEXTVAL, 'Michael Phelps', 36, 'M', 
                (SELECT ID FROM PAIS WHERE NOME = 'Estados Unidos'), 
                (SELECT ID FROM MODALIDADE WHERE NOME = 'Natação'), 
                -1.90);

    -- c)

        CREATE INDEX IDX_ATLETA_NOME ON ATLETA (NOME);

        SELECT * FROM ATLETA WHERE NOME = 'Neymar';

    -- d)

        ALTER TABLE EMISSORA_TIPO
        DISABLE CONSTRAINT CK_EMISSORA_TIPO;

        ALTER TABLE NOME_DA_TABELA
        ENABLE CONSTRAINT NOME_DA_RESTRICAO;
