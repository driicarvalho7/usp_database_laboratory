CREATE TABLE L01_PAIS (
    ID INTEGER,
    NOME VARCHAR2(150) NOT NULL,
    CONTINENTE VARCHAR2(100),
    POPULACAO NUMBER(12),

    CONSTRAINT PK_PAIS PRIMARY KEY (ID),
    CONSTRAINT UN_PAIS UNIQUE (NOME)
);

CREATE TABLE L02_OLIMPIADA (
    ANO NUMBER(4),
    PAIS VARCHAR2(150) NOT NULL,
    CIDADE_SEDE VARCHAR2(150) NOT NULL,
    DATA_INICIO DATE NOT NULL,
    DATA_ENCERRAMENTO DATE NOT NULL,

    CONSTRAINT PK_OLIMP PRIMARY KEY(ANO),
    CONSTRAINT FK_SEDE FOREIGN KEY (PAIS) REFERENCES L01_PAIS(NOME), --ON DELETE RESTRICT (DEFAULT)
    CONSTRAINT UN_OLIMP UNIQUE(CIDADE_SEDE, ANO)
);

CREATE TABLE L03_MODALIDADE (
    ID INTEGER,
    ESPORTE VARCHAR2(30) NOT NULL,
    GENERO CHAR(1) NOT NULL,

    CONSTRAINT PK_MOD PRIMARY KEY (ID),
    CONSTRAINT CK_GENERO CHECK (GENERO IN ('M', 'F')),
    CONSTRAINT UN_MOD UNIQUE(ESPORTE,GENERO)
);

CREATE TABLE L04_LOCAL(
    ID INTEGER,
    NOME VARCHAR2(200) NOT NULL,
    TIPO VARCHAR2(50),
    CAPACIDADE NUMBER(7) NOT NULL,
	  PAIS VARCHAR2(150),
    
    CONSTRAINT PK_LOCAL PRIMARY KEY(ID),
    CONSTRAINT UN_NOMELOCAL UNIQUE(NOME),
    CONSTRAINT CK_TIPO CHECK(UPPER(TIPO) IN('ESTADIO', 'GINASIO', 'PISCINA')),
    CONSTRAINT CK_CAPAC CHECK(CAPACIDADE > 5000),
	CONSTRAINT FK_LOCPAIS FOREIGN KEY(PAIS) REFERENCES L01_PAIS(NOME)
);

CREATE TABLE L05_DISPUTA(
  ID INTEGER,
  PAIS1 VARCHAR2(150) NOT NULL,
  PAIS2 VARCHAR2(150) NOT NULL,
  VENCEDOR VARCHAR2(150) NOT NULL,
  MODALIDADE INTEGER NOT NULL,
  OLIMPIADA NUMBER(4) NOT NULL,
  DATA_HORA DATE NOT NULL,
  LOCAL INTEGER NOT NULL,
  
  CONSTRAINT PK_DISPUTA PRIMARY KEY(ID),
  CONSTRAINT UN_DISPUTA UNIQUE(PAIS1, PAIS2, MODALIDADE, OLIMPIADA),
  CONSTRAINT CK_VENC CHECK(VENCEDOR = PAIS1 OR VENCEDOR = PAIS2),
  CONSTRAINT FK_PAIS1 FOREIGN KEY(PAIS1) REFERENCES L01_PAIS(NOME),
  CONSTRAINT FK_PAIS2 FOREIGN KEY(PAIS2) REFERENCES L01_PAIS(NOME),
  CONSTRAINT FK_MOD FOREIGN KEY(MODALIDADE) REFERENCES L03_MODALIDADE(ID),
  CONSTRAINT FK_OLIMP FOREIGN KEY(OLIMPIADA) REFERENCES L02_OLIMPIADA(ANO), 
  CONSTRAINT FK_LOCAL FOREIGN KEY(LOCAL) REFERENCES L04_LOCAL(ID)
);

CREATE TABLE L06_ATLETA(
  PASSAPORTE VARCHAR2(10),
  NOME VARCHAR2(200) NOT NULL,
  PAIS VARCHAR2(150) NOT NULL,
  GENERO CHAR(1) NOT NULL,
  MODALIDADE INTEGER NOT NULL,
  
  CONSTRAINT PK_ATLETA PRIMARY KEY(PASSAPORTE),
  CONSTRAINT FK_PAIS_A FOREIGN KEY(PAIS) REFERENCES L01_PAIS(NOME),
  CONSTRAINT FK_MOD_A FOREIGN KEY(MODALIDADE) REFERENCES L03_MODALIDADE(ID),
  CONSTRAINT CK_GEN_A CHECK(GENERO IN ('M','F'))
);
  
CREATE TABLE L07_JOGA(
    ATLETA VARCHAR2(10),
    DISPUTA INTEGER,
    
    CONSTRAINT PK_JOGA PRIMARY KEY(ATLETA, DISPUTA)
);

CREATE TABLE L08_PATROCINADOR(
    ID INTEGER,
    NOME VARCHAR2(200) NOT NULL,
    RAMO VARCHAR2(100) NOT NULL,
    
    CONSTRAINT PK_PAT PRIMARY KEY(ID),
    CONSTRAINT UN_NOME_PAT UNIQUE(NOME)    
);
  
CREATE TABLE L09_PATROCINA(
  PATROCINADOR INTEGER,
  ATLETA VARCHAR2(10),
  
  INICIO DATE NOT NULL,
  VIGENCIA NUMBER(3) NOT NULL,
  VALOR_TOTAL NUMBER(8) NOT NULL,
  
  CONSTRAINT PK_PATR PRIMARY KEY(PATROCINADOR, ATLETA),
  CONSTRAINT FK_PATROCINADOR FOREIGN KEY(PATROCINADOR) REFERENCES L08_PATROCINADOR(ID),
  CONSTRAINT FK_ATLETA_P FOREIGN KEY(ATLETA) REFERENCES L06_ATLETA(PASSAPORTE)  
);

CREATE TABLE L10_MIDIA(
  ID INTEGER,
  NOME VARCHAR2(100) NOT NULL,
  TIPO VARCHAR2(50) NOT NULL,
  
  CONSTRAINT PK_MIDIA PRIMARY KEY(ID),
  CONSTRAINT UN_NOME_MIDIA UNIQUE(NOME),
  CONSTRAINT CK_TIPO_MIDIA CHECK(UPPER(TIPO) IN ('RADIO','TV','STREAMING'))
);

CREATE TABLE L11_TRANSMITE(
  MIDIA INTEGER NOT NULL,
  DISPUTA INTEGER NOT NULL,
  
  CONSTRAINT PK_TRANS PRIMARY KEY(MIDIA, DISPUTA),
  CONSTRAINT FK_MIDIA FOREIGN KEY(MIDIA) REFERENCES L10_MIDIA(ID),
  CONSTRAINT FK_DISPUTA FOREIGN KEY(DISPUTA) REFERENCES L05_DISPUTA(ID)
);

CREATE SYNONYM L01 FOR L01_PAIS;
CREATE SYNONYM L02 FOR L02_OLIMPIADA;
CREATE SYNONYM L03 FOR L03_MODALIDADE;
CREATE SYNONYM L04 FOR L04_LOCAL;
CREATE SYNONYM L05 FOR L05_DISPUTA;
CREATE SYNONYM L06 FOR L06_ATLETA;
CREATE SYNONYM L07 FOR L07_JOGA;
CREATE SYNONYM L08 FOR L08_PATROCINADOR;
CREATE SYNONYM L09 FOR L09_PATROCINA;
CREATE SYNONYM L10 FOR L10_MIDIA;
CREATE SYNONYM L11 FOR L11_TRANSMITE;

CREATE SYNONYM PAIS FOR L01_PAIS;
CREATE SYNONYM OLIMPIADA FOR L02_OLIMPIADA;
CREATE SYNONYM MODALIDADE FOR L03_MODALIDADE;
CREATE SYNONYM LOCAL FOR L04_LOCAL;
CREATE SYNONYM DISPUTA FOR L05_DISPUTA;
CREATE SYNONYM ATLETA FOR L06_ATLETA;
CREATE SYNONYM JOGA FOR L07_JOGA;
CREATE SYNONYM PATROCINADOR FOR L08_PATROCINADOR;
CREATE SYNONYM PATROCINA FOR L09_PATROCINA;
CREATE SYNONYM MIDIA FOR L10_MIDIA;
CREATE SYNONYM TRANSMITE FOR L11_TRANSMITE;
