-- 2.
-- b) Escreva um trigger que impede que uma disputa seja cadastrada em um dia fora do período programado para a respectiva olimpíada.
CREATE OR REPLACE TRIGGER TRG_VALIDAR_DATA_DISPUTA
BEFORE INSERT OR UPDATE ON L05_DISPUTA
FOR EACH ROW
DECLARE
  v_data_inicio L02_OLIMPIADA.DATA_INICIO%TYPE;
  v_data_encerramento L02_OLIMPIADA.DATA_ENCERRAMENTO%TYPE;
BEGIN
  -- Buscar o período da Olimpíada
  SELECT DATA_INICIO, DATA_ENCERRAMENTO
  INTO v_data_inicio, v_data_encerramento
  FROM L02_OLIMPIADA
  WHERE ANO = :NEW.OLIMPIADA;

  -- Verifica se a 'DATA_HORA' inserida está entre o período da Olimpiada.
  IF :NEW.DATA_HORA < v_data_inicio OR :NEW.DATA_HORA > v_data_encerramento THEN
    RAISE_APPLICATION_ERROR(-20001, 'A data da disputa deve estar dentro do período da Olimpíada.');
  END IF;
END;
/

INSERT INTO L05_DISPUTA
    (ID, PAIS1, PAIS2, VENCEDOR, MODALIDADE, OLIMPIADA, DATA_HORA, LOCAL) 
VALUES 
    (333777, 'Brasil', 'Alemanha', 'Brasil', 2, 2016, TO_DATE('2016-08-31 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1);

-- c) Escreva um trigger para impedir que um atleta jogue em uma modalidade diferente daquela declarada em seu  registro na tabela L06_ATLETA, impedindo a inserção na tabela L07_JOGA.
CREATE OR REPLACE TRIGGER TRG_VALIDAR_MODALIDADE_ATLETA
BEFORE INSERT ON L07_JOGA
FOR EACH ROW
DECLARE
  v_modalidade_atleta L06_ATLETA.MODALIDADE%TYPE;
  v_modalidade_disputa L05_DISPUTA.MODALIDADE%TYPE;
BEGIN
  -- Buscar a modalidade do atleta na tabela L06_ATLETA
  SELECT MODALIDADE
  INTO v_modalidade_atleta
  FROM L06_ATLETA
  WHERE PASSAPORTE = :NEW.ATLETA;

  -- Buscar a modalidade da disputa na tabela L05_DISPUTA
  SELECT MODALIDADE
  INTO v_modalidade_disputa
  FROM L05_DISPUTA
  WHERE ID = :NEW.DISPUTA;

  -- Verificar se a modalidade da disputa é a mesma da modalidade do atleta
  IF v_modalidade_atleta != v_modalidade_disputa THEN
    RAISE_APPLICATION_ERROR(-20002, 'O atleta só pode participar de disputas na modalidade registrada.');
  END IF;
END;
/


INSERT INTO L07_JOGA (ATLETA, DISPUTA) VALUES ('FR13578', 5);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3.
-- Criando a tabela de output referente a página 7 dos slides em 'Aula05_Triggers.pdf'
DROP TABLE output;
CREATE TABLE output(iNr NUMBER, operacao VARCHAR2(30), msg varchar2(200));
Drop sequence op_seq;
CREATE SEQUENCE op_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER TRG_AUDITAR_DISPUTA
AFTER INSERT OR UPDATE OR DELETE ON L05_DISPUTA
FOR EACH ROW
DECLARE
  operacao VARCHAR2(30);
BEGIN
  -- Identificar o tipo de operação
  IF INSERTING THEN operacao := 'INSERT';
    ELSIF UPDATING THEN operacao := 'UPDATE';
    ELSIF DELETING THEN operacao := 'DELETE';
  END IF;

  -- Registrar os valores antigos (para UPDATE e DELETE) e novos (para INSERT e UPDATE)
  IF DELETING OR UPDATING THEN
    INSERT INTO output VALUES(op_seq.NEXTVAL, operacao, :OLD.PAIS1 || ' vs ' || :OLD.PAIS2 || ' - ' || :OLD.VENCEDOR);
  END IF;
  
  IF INSERTING OR UPDATING THEN
    INSERT INTO output VALUES(op_seq.NEXTVAL, operacao, :NEW.PAIS1 || ' vs ' || :NEW.PAIS2 || ' - ' || :NEW.VENCEDOR);
  END IF;
  
  -- Inserir um separador para as operações no log
  INSERT INTO output VALUES(0, '------------', '-----------');
END;
/


UPDATE L05_DISPUTA SET PAIS2 = 'Brasil', DATA_HORA = TO_DATE('2021-07-29 10:00', 'YYYY-MM-DD HH24:MI') WHERE ID = 529;

SELECT * FROM output;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4.
-- Realizando uma consulta para ver o estado anterior do nome do país
SELECT * FROM L01_PAIS WHERE NOME = 'Nigéria';
SELECT * FROM L02_OLIMPIADA WHERE PAIS = 'Nigéria';
SELECT * FROM L04_LOCAL WHERE PAIS = 'Nigéria';
SELECT * FROM L05_DISPUTA WHERE PAIS1 = 'Nigéria' OR PAIS2 = 'Nigéria' OR VENCEDOR = 'Nigéria';
SELECT * FROM L06_ATLETA WHERE PAIS = 'Nigéria';


CREATE OR REPLACE TRIGGER trg_update_cascade_pais
AFTER UPDATE OF NOME ON L01_PAIS
FOR EACH ROW
BEGIN
  -- Atualizar o nome do país na tabelas
  UPDATE L02_OLIMPIADA
  SET PAIS = :NEW.NOME
  WHERE PAIS = :OLD.NOME;

  UPDATE L04_LOCAL
  SET PAIS = :NEW.NOME
  WHERE PAIS = :OLD.NOME;

  UPDATE L05_DISPUTA
  SET PAIS1 = :NEW.NOME
  WHERE PAIS1 = :OLD.NOME;

  UPDATE L05_DISPUTA
  SET PAIS2 = :NEW.NOME
  WHERE PAIS2 = :OLD.NOME;

  UPDATE L05_DISPUTA
  SET VENCEDOR = :NEW.NOME
  WHERE VENCEDOR = :OLD.NOME;

  UPDATE L06_ATLETA
  SET PAIS = :NEW.NOME
  WHERE PAIS = :OLD.NOME;
END;
/

-- Desabilitando Check de vencedor pois o trigger não estava sendo executado por conta dele
ALTER TABLE L05_DISPUTA DISABLE CONSTRAINT CK_VENC;

UPDATE L01_PAIS SET NOME = 'Nigéria CASCADE' WHERE ID = 15; 

ALTER TABLE L05_DISPUTA ENABLE CONSTRAINT CK_VENC;

-- Realizando uma consulta para ver o estado posterior do nome do país
SELECT * FROM L01_PAIS WHERE NOME = 'Nigéria CASCADE';
SELECT * FROM L02_OLIMPIADA WHERE PAIS = 'Nigéria CASCADE';
SELECT * FROM L04_LOCAL WHERE PAIS = 'Nigéria CASCADE';
SELECT * FROM L05_DISPUTA WHERE PAIS1 = 'Nigéria CASCADE' OR PAIS2 = 'Nigéria CASCADE' OR VENCEDOR = 'Nigéria CASCADE';
SELECT * FROM L06_ATLETA WHERE PAIS = 'Nigéria CASCADE';